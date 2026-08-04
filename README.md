<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/images/logos/bina_logo_blue.png">
    <img src="assets/images/logos/bina_logo_dark.png" alt="Bina logo" width="170" height="380">
  </picture>
</p>

<h1 align="center">BinaApp</h1>

Bina is a Flutter application for at-home dental screening. It pairs with a small custom camera device over WiFi Direct, streams MJPEG video from an oral cavity endoscope, runs on-device YOLO inference to spot cavities, guides users through a structured mouth-region calibration, keeps a household of family members with individual histories, and layers a fully local Gemma-based assistant on top with retrieval augmented generation over uploaded medical documents.


---

## Table of Contents

1. [Overview](#overview)
2. [Code Tour](#code-tour)
3. [Repository Layout](#repository-layout)
4. [Getting Started](#getting-started)
5. [Dependencies](#dependencies)
6. [Application Pages](#application-pages)
7. [Camera and Hardware Stack](#camera-and-hardware-stack)
8. [On-device Machine Learning](#on-device-machine-learning)
9. [Gemma Assistant](#gemma-assistant)
10. [Embeddings and RAG](#embeddings-and-rag)
11. [Family Analytics and Health Reports](#family-analytics-and-health-reports)
12. [Design System](#design-system)
13. [Accessibility, Nielsen Heuristics, Localization](#accessibility-nielsen-heuristics-localization)
14. [State Management and Data Layer](#state-management-and-data-layer)
15. [Known Limitations](#known-limitations)
16. [Suggested Additions](#suggested-additions)

---

## Overview

Bina targets a household of casual users, not clinicians. A parent scans everyone in the family, keeps the images on-device, gets an on-device YOLO cavity detection overlay, then optionally hands the resulting session to a locally running Gemma model to produce a plain-language summary, answer follow-up questions, or export a PDF health report to send to a dentist.

The stack is intentionally offline-first. The only network dependency is Supabase for cloud sync of session data and pgvector search; every model (YOLO, EmbeddingGemma-300M, Gemma 3 1B, Gemma 4 E2B) runs on the phone.

<details>
<summary>Feature summary</summary>

- WiFi Direct pairing with a custom camera device (PIN 12345678)
- MJPEG live view at `http://<camera>:8070/stream.mjpg`
- Real-time YOLO cavity detection overlay drawn on every stream frame
- IMU (LIS3DH) pitch/roll read from the camera and mapped to a mouth region
- 14-region calibration procedure with circular-mean angle averaging
- Per-image Gemma interpretation, end-of-session Gemma summary, PDF export
- Household with separate profiles, dental history, and analytics per member
- PDF and text document uploads, chunked and embedded with EmbeddingGemma
- RAG-backed chat that grounds Gemma replies in the current family member's documents
- Command-tag protocol so Gemma can navigate the app or trigger scans
- Five themes, four languages including Hebrew RTL, age-aware text scaling

</details>

---

## Code Tour

A set of links to methods worth reviewing.

<details>
<summary>Gemma Agent</summary>

### Gemma agent features

| What | Where |
| --- | --- |
| Agent entry point `processMessage` (language detect → RAG → prompt → generate → parse → execute → follow-up) | [`gemma_agent_service.dart:88`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L88) |
| Top-K RAG retrieval call inside the agent | [`gemma_agent_service.dart:120`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L120) |
| System prompt assembly | [`gemma_agent_service.dart:131`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L131) |
| Follow-up Gemma turn after a data-query command executes | [`gemma_agent_service.dart:243`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L243) |
| `_isResponseQuestion` heuristic (suppresses navigation when the model asked a question) | [`gemma_agent_service.dart:303`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L303) |
| Hebrew phrase list for the question-check | [`gemma_agent_service.dart:321`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/gemma_agent_service.dart#L321) |
| 1500-char passage budget for RAG block | [`agent_prompts.dart:11`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/agent_prompts.dart#L11) |
| Anti-hallucination line ("The passages above ARE the text extracted...") | [`agent_prompts.dart:69`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/agent_prompts.dart#L69) |
| Reference passages block builder | [`agent_prompts.dart:80`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/agent_prompts.dart#L80) |
| Command whitelist | [`command_parser.dart:50`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/command_parser.dart#L50) |
| Command regex patterns (`[CMD:...]` and `[...]` forms) | [`command_parser.dart:39`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/command_parser.dart#L39) |
| `parse()` main routine | [`command_parser.dart:65`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/command_parser.dart#L65) |
| CommandDefinition declaration and full command list | [`command_registry.dart:42`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/command_registry.dart#L42) |
| Family term map (English + Hebrew + Indonesian + Malay) | [`member_name_resolver.dart:9`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/member_name_resolver.dart#L9) |
| Levenshtein fuzzy-match | [`member_name_resolver.dart:180`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_agent/member_name_resolver.dart#L180) |
| GemmaModel enum (bundled 1B vs downloaded E2B) | [`gemma_service.dart:11`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_service.dart#L11) |
| Which model is active | [`gemma_service.dart:89`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_service.dart#L89) |
| `resetModel` to clear KV cache between chats | [`gemma_service.dart:110`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gemma_service.dart#L110) |
| Static prompts (image interpretation, session summary, chat context) | [`llm_prompts.dart:5`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/llm_prompts.dart#L5) |
</details>

<details>
<summary>Embeddings and RAG</summary>

### Embeddings and RAG features

| What | Where |
| --- | --- |
| Task prefixes (`title: none | text:` for docs, `task: search result | query:` for queries) | [`embedding_service.dart:16`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding_service.dart#L16) |
| Init-time smoke test | [`embedding_service.dart:44`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding_service.dart#L44) |
| Document embedding wrapper | [`embedding_service.dart:91`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding_service.dart#L91) |
| Query embedding wrapper | [`embedding_service.dart:96`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding_service.dart#L96) |
| `retrieveTopK` (dispatches local vs cloud) | [`chunk_retriever.dart:45`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/chunk_retriever.dart#L45) |
| Local linear cosine scan | [`chunk_retriever.dart:76`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/chunk_retriever.dart#L76) |
| Cloud pgvector RPC (`match_document_chunks`) | [`chunk_retriever.dart:105`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/chunk_retriever.dart#L105) |
| Alignment-safe `Uint8List` → `Float32List` decoder (with the multiple-of-4 caveat) | [`chunk_retriever.dart:139`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/chunk_retriever.dart#L139) |
| Chunker boundary-preference algorithm | [`text_chunker.dart:13`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/text_chunker.dart#L13) |
| Chunker paragraph/sentence/whitespace fallback logic | [`text_chunker.dart:29`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/embedding/text_chunker.dart#L29) |
| Upload pipeline (`pickAndExtract`) | [`member_document_service.dart:56`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/member_document_service.dart#L56) |
| AttachProgress state machine (saving → embedding → done) | [`member_document_service.dart:33`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/member_document_service.dart#L33) |
| 40-char threshold that rejects scanned-image PDFs | [`member_document_service.dart:54`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/member_document_service.dart#L54) |
</details>

<details>
<summary>Camera, gyro, YOLO</summary>

### Camera, gyro, YOLO features

| What | Where |
| --- | --- |
| Real-time 500 ms YOLO loop | [`photo_session_widget.dart:210`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/photo_session/photo_session_widget.dart#L210) |
| Bounding-box overlay painter | [`photo_session_widget.dart:263`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/photo_session/photo_session_widget.dart#L263) |
| Session finalisation with uncovered-region warning | [`photo_session_widget.dart:691`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/photo_session/photo_session_widget.dart#L691) |
| YOLO interpreter setup with GPU delegate on Android | [`yolo_inference_native.dart:45`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/custom_code/actions/yolo_inference_native.dart#L45) |
| Confidence threshold (`0.15`) | [`yolo_inference_native.dart:35`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/custom_code/actions/yolo_inference_native.dart#L35) |
| Lite vs full inference (draw or skip) | [`yolo_inference_native.dart:276`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/custom_code/actions/yolo_inference_native.dart#L276) |
| Class labels list (currently single-class `Cavity`) | [`run_yolo_inference.dart:36`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/custom_code/actions/run_yolo_inference.dart#L36) |
| Mouth-region weighted 2-NN `estimate` | [`mouth_region_estimator.dart:35`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/mouth_region_estimator.dart#L35) |
| Wraparound-aware angular distance | [`mouth_region_estimator.dart:25`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/mouth_region_estimator.dart#L25) |
| `uncoveredRegions` | [`mouth_region_estimator.dart:69`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/mouth_region_estimator.dart#L69) |
| Default 14-region calibration table | [`mouth_region_estimator.dart:84`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/mouth_region_estimator.dart#L84) |
| Calibration 20-sample circular-mean averaging (`atan2` over sin/cos sums) | [`calibration_widget.dart:140`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/calibration/calibration_widget.dart#L140) |
| Camera-disconnected snackbar in calibration | [`calibration_widget.dart:43`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/calibration/calibration_widget.dart#L43) |
| WiFi Direct MethodChannel and EventChannels | [`wifi_direct_service.dart:66`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/wifi_direct_service.dart#L66) |
| Shared PIN `12345678` in `connectToBinaCamera` | [`wifi_direct_service.dart:254`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/wifi_direct_service.dart#L254) |
| Auto-connect when a `Bina` device is seen | [`camera_connection_widget.dart:155`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/camera_connection/camera_connection_widget.dart#L155) |
| "No Bina camera detected" snackbar with "Show all" action | [`camera_connection_widget.dart:137`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/other_pages/camera_connection/camera_connection_widget.dart#L137) |
| Gyro self-heal in `readOrientationInts` | [`gyro_controller_service.dart:257`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/gyro_controller_service.dart#L257) |
</details>

<details>
<summary>Health report, family, UX</summary>

### Health report, family, UX features

| What | Where |
| --- | --- |
| `HealthReportService.exportAndShare` entry | [`health_report_service.dart:76`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/health_report_service.dart#L76) |
| `buildPayload` (last five sessions + Gemma trend paragraph) | [`health_report_service.dart:90`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/health_report_service.dart#L90) |
| Gemma trend-paragraph prompt | [`health_report_service.dart:251`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/health_report_service.dart#L251) |
| Auto-attach exported PDF back into RAG document store | [`health_report_service.dart:345`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/health_report_service.dart#L345) |
| Share sheet call (`Printing.sharePdf`) | [`health_report_service.dart:368`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/health_report_service.dart#L368) |
| Sign-out confirmation dialog | [`main_profile_page_widget.dart:63`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/nav_pages/main_profile_page/main_profile_page_widget.dart#L63) |
| Delete-family-member with cascade delete of sessions, images, calibrations, documents | [`family_widget.dart:347`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/family/family/family_widget.dart#L347) |
| Cascade in action | [`family_widget.dart:402`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/pages/family/family/family_widget.dart#L402) |
</details>

<details>
<summary>Design system and accessibility</summary>

### Design system and accessibility features

| What | Where |
| --- | --- |
| Responsive breakpoints (`720`, `1100`) | [`bina_responsive.dart:24`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/bina_design/bina_responsive.dart#L24) |
| Breakpoint resolver | [`bina_responsive.dart:30`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/bina_design/bina_responsive.dart#L30) |
| Bina design tokens (colours, space, radius) | [`bina_design_tokens.dart:36`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/bina_design/bina_design_tokens.dart#L36) |
| Five-theme enum (light, dark, warm, cool, deuteranopia) | [`app_theme_type.dart:8`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/app_core/app_theme_type.dart#L8) |
| Text-scale enum (small, medium, large, extra-large) | [`text_scale.dart:5`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/app_core/text_scale.dart#L5) |
| `suggestedForAge` (65+ → large, 75+ → extra-large) | [`text_scale.dart:30`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/app_core/text_scale.dart#L30) |
| AccessibilitySettingsService state and persistence | [`accessibility_settings_service.dart:28`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/services/accessibility_settings_service.dart#L28) |
| Localization: four supported languages | [`internationalization.dart:16`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/app_core/internationalization.dart#L16) |
| Translation map | [`internationalization.dart:150`](https://github.com/vitrobiani/BinaApp/blob/55ea52cc70aff3e59a1d16c21c744c70d0a53c07/lib/app_core/internationalization.dart#L150) |
</details>

---

## Repository Layout

```
lib/
  actions/                    Reusable navigation and business actions
  app_core/                   Themes, i18n, custom functions, app-wide utils
  auth/                       Supabase authentication wrappers
  backend/
    schema/                   Generated structs and enums
    sqlite/                   SQLite manager, migrations, DAOs
    supabase/                 Supabase table bindings and RPC calls
  bina_design/                Design tokens, responsive layout, shared widgets
  components/                 Reusable widgets: dialogs, banners, loaders
  custom_code/actions/        Hand-written actions including YOLO inference
  pages/
    accessibility_pages/      Dedicated theme/text/language screens
    family/                   Household, member detail, documents
    nav_pages/                Home, diagnostics, profile, chat
    other_pages/              Camera connection, calibration, photo session, summary
  services/                   Service singletons (see below)
```

The services layer holds most of the interesting logic and is where you should look first.

<details>
<summary>Services directory</summary>

| File | Purpose |
| --- | --- |
| [`gemma_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_service.dart) | Singleton wrapper around `flutter_gemma`, model selection, generation |
| [`embedding_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding_service.dart) | ONNX EmbeddingGemma-300M runtime, 768-dim L2-normalised vectors |
| [`embedding/chunk_retriever.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/chunk_retriever.dart) | Top-K cosine retrieval, local scan or Supabase pgvector RPC |
| [`embedding/text_chunker.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/text_chunker.dart) | Boundary-aware chunking with overlap |
| [`embedding/gemma_tokenizer.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/gemma_tokenizer.dart) | BPE tokenizer with byte fallback, loaded off the UI isolate |
| [`gemma_agent/gemma_agent_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/gemma_agent_service.dart) | Orchestrates language detection, retrieval, prompt, command execution |
| [`gemma_agent/agent_prompts.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/agent_prompts.dart) | System prompt, command reference, RAG passage block |
| [`gemma_agent/command_parser.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/command_parser.dart) | Regex-based command extraction |
| [`gemma_agent/command_registry.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/command_registry.dart) | Declarative catalog of every command |
| [`gemma_agent/command_executor.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/command_executor.dart) | Runs data queries for self and family members |
| [`gemma_agent/member_name_resolver.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/member_name_resolver.dart) | Multilingual fuzzy resolver for family terms |
| [`gemma_agent/navigation_executor.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/navigation_executor.dart) | Applies navigation intents from parsed commands |
| [`gemma_agent/action_executor.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/action_executor.dart) | Applies action intents (start scan, add member) |
| [`gemma_agent/response_formatter.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/response_formatter.dart) | Formats DB results as text ready for the follow-up turn |
| [`chat_manager.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/chat_manager.dart) | Conversation persistence in SQLite |
| [`llm_prompts.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/llm_prompts.dart) | Static prompts for image interpretation and session summary |
| [`member_document_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/member_document_service.dart) | PDF/text upload, chunking, embedding, storage |
| [`wifi_direct_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/wifi_direct_service.dart) | MethodChannel bridge to Android WiFi Direct APIs |
| [`mjpeg_capture_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/mjpeg_capture_service.dart) | Snapshot and stream frame extraction |
| [`mouth_region_estimator.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/mouth_region_estimator.dart) | Weighted 2-NN over calibration points, wraparound-aware distance |
| [`motor_controller_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/motor_controller_service.dart) | REST client for stepper motor on the camera board |
| [`gyro_controller_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gyro_controller_service.dart) | REST client for LIS3DH IMU, self-heals from AppState |
| [`health_report_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/health_report_service.dart) | Aggregates history, calls Gemma for trend paragraph, builds and shares PDF |
| [`accessibility_settings_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/accessibility_settings_service.dart) | Text scale, contrast, motion, hint mode, haptics |

</details>

---

## Getting Started

Requires Flutter with Dart SDK `>=3.0.0` and Android tooling. iOS builds are configured but the Gemma inference path is tuned for Android (GPU delegate is Android-only).

```bash
flutter pub get
flutter run
```

The application boots to the sign-in screen. Sign in with Supabase credentials, then choose or create a family member. Bundled Gemma 3 1B is used by default; downloading Gemma 4 E2B (2.6 GB) is triggered from the profile page and pulls from HuggingFace.

To pair with the camera, tap the camera icon in the diagnostics page. The app will scan for a device whose name starts with `Bina` and connect automatically using the shared PIN `12345678`. If auto-connect fails a manual IP entry is offered.

---

## Dependencies

<details>
<summary>Key packages from pubspec.yaml</summary>

| Package | Version | Role |
| --- | --- | --- |
| `flutter_gemma` | ^0.15.0 | On-device Gemma inference |
| `flutter_onnxruntime` | ^1.8.3 | EmbeddingGemma inference |
| `tflite_flutter` | 0.12.1 | YOLO cavity detector |
| `mjpeg_stream` | ^1.0.1 | Live camera stream |
| `supabase_flutter` | 2.9.0 | Cloud sync and auth |
| `syncfusion_flutter_pdf` | ^30.1.42 | PDF text extraction and generation |
| `printing` | ^5.13.0 | Share sheet PDF export |
| `sqflite` | 2.3.3+1 | Local session and chat storage |
| `go_router` | 12.1.3 | Declarative routing |
| `provider` | 6.1.5 | State management for AppState and models |
| `google_fonts` | ^6.2.1 | Readex Pro and Inter typefaces |
| `file_picker` | 10.1.9 | Document uploads |
| `image_picker` | 1.1.2 | Gallery selection |
| `permission_handler` | ^11.3.0 | Camera, storage, location for WiFi Direct |
| `http` | | Motor and gyro REST clients |

</details>

<details>
<summary>Assets that ship with the app</summary>

- `assets/models/cavity_detector_no_nms.tflite` — YOLO cavity detector without NMS baked in
- `assets/models/yolo11n_float16.tflite`, `best_model.tflite` — earlier candidates kept for comparison
- `assets/model/embeddings/model_quantized.onnx` and `.onnx_data` — EmbeddingGemma-300M
- `assets/model/embeddings/tokenizer.json`, `tokenizer_config.json`, `special_tokens_map.json`, `config`
- Gemma 3 1B is bundled inside the flutter_gemma asset payload
- Gemma 4 E2B is fetched on demand at runtime

</details>

---

## Application Pages

<details>
<summary>Navigation surface</summary>

| Area | Widget | Notes |
| --- | --- | --- |
| Home | [`main_home_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/nav_pages/main_home/main_home_widget.dart) | Hero progress rings, family ribbon, three-column responsive layout |
| Diagnostics | [`main_d_iagnostics_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/nav_pages/main_d_iagnostics/main_d_iagnostics_widget.dart) | Live YOLO overlay, gyro region readout, motor rotation entry point |
| Profile | [`main_profile_page_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/nav_pages/main_profile_page/main_profile_page_widget.dart) | Theme picker, model download trigger, sign-out confirmation |
| Camera pairing | [`camera_connection_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/camera_connection/camera_connection_widget.dart) | 15 s scan, auto-connect on `Bina` device, manual IP fallback |
| Calibration | [`calibration_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/calibration/calibration_widget.dart) | 14 mouth regions, 20-sample circular mean, skip options |
| Photo session | [`photo_session_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/photo_session/photo_session_widget.dart) | 500 ms YOLO tick, bounding boxes, uncovered-region warning |
| Diagnosis result | [`diagnosis_result_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/diagnosis_result/diagnosis_result_widget.dart) | Colour-coded issue chips, confidence badges |
| Session summary | [`session_summary_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/session_summary/session_summary_widget.dart) | End-of-session Gemma narrative, note save |
| Session details | [`session_details_page.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/session_details_page.dart) | Grid of annotated and original images |
| Family list | [`family_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/family/family/family_widget.dart) | Per-member tally, master-detail on desktop, delete confirm |
| Member detail | [`member_detail_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/family/member_detail/member_detail_widget.dart) | Session list, delete cascade, PDF export button |
| Member documents | [`member_documents_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/family/member_documents/member_documents_widget.dart) | Upload with 3-stage progress, swipe to delete |
| Accessibility hub | [`accessibility_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/accessibility/accessibility_widget.dart) | One-stop for theme, language, text size, motion, haptics |

</details>

---

## Camera and Hardware Stack

The camera device runs three services on a single board.

| Port | Service | Client |
| --- | --- | --- |
| 8070 | MJPEG stream and snapshot endpoint | [`MjpegCaptureService`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/mjpeg_capture_service.dart) |
| 8071 `/status`, `/move`, `/rotate`, `/stop`, `/enable`, `/disable`, `/led` | Stepper motor for the intraoral scan head | [`MotorControllerService`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/motor_controller_service.dart) |
| 8071 `/gyro`, `/gyro/accel`, `/gyro/orientation`, `/gyro/status` | LIS3DH IMU pitch/roll for mouth-region tracking | [`GyroControllerService`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gyro_controller_service.dart) |

### Pairing

WiFi Direct is handled through a MethodChannel named `com.bina.system/wifi_direct`, defined in [`wifi_direct_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/wifi_direct_service.dart). Discovery streams device names and MAC addresses back to Dart via an event channel. `connectToBinaCamera()` picks the first device whose name begins with `Bina` and passes the shared PIN `12345678`.

Once paired, `AppState.cameraConnection.cameraHost` holds the IP that all three services above key off. `GyroControllerService.readOrientationInts()` self-heals: if it is asked for a reading before anyone called `configure()`, it consults AppState and configures itself, so downstream capture flows can just call the read and get either integers or `(null, null)` if the camera is gone.

### Live view

The MJPEG stream is consumed by `mjpeg_stream` for display. In parallel, [`MjpegCaptureService`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/mjpeg_capture_service.dart) makes its own HTTP requests to `snapshot.jpg` or to the stream endpoint, walking JPEG start (`0xFFD8`) and end (`0xFFD9`) markers to extract single frames for the YOLO tick. Keeping the snapshot channel separate from the on-screen video means the preview never stutters when a frame is grabbed for inference.

### Motor rotation

In the diagnostics page, the user can request a half-revolution scan sweep via `MotorControllerService.rotate(revolutions: 0.5)`. The service uses a longer 15-second timeout for rotation to accommodate the physical motion.

---

## On-device Machine Learning

### YOLO cavity detection

Cavity detection runs entirely on the phone through `tflite_flutter`. The heart of it is in [`yolo_inference_native.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/custom_code/actions/yolo_inference_native.dart). Highlights:

- Model file: `assets/models/cavity_detector_no_nms.tflite`
- Interpreter: 4 threads, `GpuDelegateV2` on Android for real-time performance
- Minimum confidence threshold: `0.15`
- Class labels: single class `Cavity` (kept as a list in [`run_yolo_inference.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/custom_code/actions/run_yolo_inference.dart) so it is trivial to extend to the earlier multi-class version)

The public entry points come in two flavours. `runYoloInference(imagePath)` saves an annotated image to disk and is used when a still is captured. `runYoloInferenceLite(imagePath)` skips drawing and saving and is used by the 500 ms real-time loop that overlays boxes directly on the live view.

### Real-time overlay

In [`photo_session_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/photo_session/photo_session_widget.dart), `_startRealtimeAnalysis()` sets up a 500 ms `Timer.periodic` that grabs a snapshot, feeds it through `runYoloInferenceLite`, and stores detections in state. `_buildDetectionOverlay()` transforms those pixel coordinates into the on-screen preview coordinate space and paints boxes with class-specific colours. Because inference and drawing are decoupled from the MJPEG stream, the video keeps playing smoothly even when a frame is dropped.

### Mouth region estimator

Every time a photo is captured, the app asks the gyro for pitch and roll and hands them to [`MouthRegionEstimator`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/mouth_region_estimator.dart). The estimator holds a set of calibration points, one per named mouth region. `estimate()` returns either a single region or an ambiguous `R1/R2` string when two neighbours score almost identically.

Distance is computed with a wraparound-aware angular metric so that pitch or roll near ±180° does not falsely look far away from its own neighbour. The final region is chosen with a weighted 2-nearest-neighbour vote rather than a hard argmin, which produces much smoother behaviour when the head is between regions. `uncoveredRegions()` compares the set of visited regions in the current session to the 14 calibrated positions and returns the missing ones, which drives the "you haven't scanned area X yet" warning at the end of a session.

The default calibration ships fourteen hard-coded regions covering upper and lower jaw, front, top, right, left, inner, and outer.

---

## Gemma Assistant

Gemma is treated as a first-class part of the app, not a bolt-on chat panel. It is used for four distinct purposes:

1. **Per-image interpretation** during a photo session
2. **End-of-session narrative summary** on the session summary screen
3. **Trend paragraph** inside the exported PDF health report
4. **Conversational assistant** with retrieval augmentation and command execution

### Model management

[`GemmaService`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_service.dart) is a singleton that wraps the `flutter_gemma` plugin. It exposes a `GemmaModel` enum with two entries:

| Model | Source | Size | Notes |
| --- | --- | --- | --- |
| `gemma3_1b` | Bundled in app assets | ~555 MB | Default fallback, fast, weaker quality |
| `gemma4_e2b` | HuggingFace download at runtime | ~2.6 GB | Preferred, better multilingual, higher quality |

`_selectedModel` defaults to `gemma4_e2b`. On first use the service checks whether the E2B weights are cached, prompts for download if not, and falls back to the bundled 1B model if the user cancels or is offline. Generation parameters are `temperature: 0.7`, `topK: 40`. `resetModel()` clears the underlying conversation state without unloading the weights, which matters because a Gemma session accumulates KV cache and can start refusing long user turns after enough back-and-forth.

### Static prompts

[`llm_prompts.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/llm_prompts.dart) collects the small, single-shot prompts used outside of the chat agent:

- `chatbotSystemPrompt` for the plain (non-agentic) chat path
- `buildImageInterpretationPrompt` for per-photo notes during a session
- `buildSessionSummaryPrompt` for the end-of-session narrative
- `buildChatContextPrompt` for chat-tab conversation seeding

Keeping them here means the prompt strings live outside of any widget and can be reviewed and iterated on without touching UI code.

### Agentic path

The interesting one is [`gemma_agent_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/gemma_agent_service.dart). `processMessage(userText)` does the following in order:

1. Detect Hebrew via the regex `[֐-׿]` and set a language flag
2. Retrieve top-K RAG chunks for the active family member from the local or cloud embedding index
3. Build the system prompt (see next section)
4. Call `GemmaService.generateResponse`
5. Parse any `[COMMAND|arg]` tags out of the reply
6. Execute the parsed commands (data query, navigation, or action)
7. If the executed command was a data query, format the results back as text and run a follow-up Gemma turn so the model can talk over the fresh data

Whether the model's reply itself is treated as a question is decided by `_isResponseQuestion()`. If the reply ends with `?`, or the Hebrew maqaf `׃`, or contains framing phrases like "would you like" or "האם תרצה", navigation intents are suppressed for that turn so the user is not yanked away from a question they were just asked.

### System prompt and command reference

[`agent_prompts.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/agent_prompts.dart) assembles the system prompt. Its structure:

- Role and rules
- A short command reference table listing tags like `[GET_MY_SCANS]`, `[EXPLAIN_MY_LAST_SCAN]`, `[NAV_HOME]`, `[START_SCAN_SELECT]`
- A "Reference passages" block, budgeted at 1500 characters, populated from the top RAG chunks
- Explicit anti-hallucination language: *"The passages above ARE the text extracted from the user's uploaded documents/PDFs/files"*, so the model does not disclaim its own retrieved evidence

The passage budget is deliberately small. Gemma 3 1B behaves noticeably worse when its context is stuffed, so the retriever aims for a handful of high-signal chunks rather than a wide net.

### Command parser and registry

[`command_parser.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/command_parser.dart) uses the regex `\[([A-Z][A-Z_]+)(?:\|([^\]]+))?\]` and filters against a whitelist. [`command_registry.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/command_registry.dart) is the source of truth: every command has a name, a type (`dataQuery`, `navigation`, or `action`), an optional parameter, and worked examples in English and Hebrew. The registry is what the prompt table is rendered from, which means adding a new command is a one-file change.

<details>
<summary>Command types</summary>

- **Data query** — Runs against SQLite/Supabase, returns rows. Examples: `[GET_MY_SCANS]`, `[SEARCH_MY_DIAGNOSES|cavity]`, `[GET_MEMBER_LAST_SCAN|Dad]`
- **Navigation** — Triggers `go_router` navigation. Examples: `[NAV_HOME]`, `[NAV_FAMILY]`, `[NAV_MEMBER|Ada]`
- **Action** — Kicks off a user flow. Examples: `[START_SCAN_SELECT]`, `[START_SCAN]`, `[ADD_FAMILY_MEMBER]`

</details>

### Family member resolution

Users refer to family members by name, but also by role: "mom", "dad", "אבא", "ibu", "ayah". [`member_name_resolver.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/gemma_agent/member_name_resolver.dart) holds a `familyTerms` map with English, Hebrew, Indonesian, and Malay for mother, father, grandmother, grandfather, brother, sister, son, daughter. Free-text names get a Levenshtein match with distance up to 2 for tolerance to typos and transliteration.

### Interpretation, summary, and trend

Beyond conversation, Gemma is used silently at three points:

- After a photo is captured, `photo_session_widget.dart` calls `buildImageInterpretationPrompt` and shows the interpretation as a per-image note
- At the end of a session, `session_summary_widget.dart` builds a session-level prompt from the aggregated findings and animates in the resulting paragraph
- When exporting a health report, [`health_report_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/health_report_service.dart) queries the last five sessions, asks Gemma for a short trend paragraph, and embeds it in the PDF

---

## Embeddings and RAG

The RAG layer is the most nuanced part of the app and the one worth showing off to an NLP reviewer.

### Model

The embedding model is EmbeddingGemma-300M, quantised to ONNX, running through `flutter_onnxruntime`. It produces 768-dimensional vectors and is invoked from [`embedding_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding_service.dart). On first run the ONNX weights and data file are staged from bundled assets into the app support directory (ONNX Runtime insists on a real filesystem path for the `.onnx_data` sidecar). A smoke test embedding is generated on init to catch a broken tokenizer or runtime early.

### Task prefixes

EmbeddingGemma is trained with instruction prefixes and the app applies them:

- Document text: `"title: none | text: <chunk>"`
- Query text: `"task: search result | query: <question>"`

Vectors are L2 normalised so cosine similarity is a dot product.

### Tokenizer

[`gemma_tokenizer.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/gemma_tokenizer.dart) is a full BPE implementation with `byte_fallback`, `fuse_unk`, and `TemplateProcessing`, driven by the ~20 MB HuggingFace `tokenizer.json`. Loading is done through `compute()` so it does not stall the UI. Sequences are capped at 2048 tokens which is far larger than any single chunk we produce.

### Chunking

[`text_chunker.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/text_chunker.dart) provides `chunk(raw, targetChars=500, overlapChars=50)`. It prefers paragraph boundaries, then sentence terminators (`.`, `!`, `?`, and the Hebrew sof pasuq `׃`), then whitespace, before falling back to a hard cut. The 50-character overlap keeps entities that straddle boundaries reachable from either side.

### Storage and retrieval

[`chunk_retriever.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/embedding/chunk_retriever.dart) offers a unified `retrieveTopK(memberId, query, k=4)`. Under the hood there are two paths:

- **Local**: chunks are stored in SQLite with the embedding as a `Uint8List` blob. Retrieval decodes to `Float32List` and does a linear cosine scan. Fast enough for a household even at thousands of chunks.
- **Cloud**: chunks are also mirrored to Supabase with a `vector(768)` column. Retrieval calls the Postgres RPC `match_document_chunks`, which uses an HNSW index on top of pgvector.

Both paths return a `List<RetrievedChunk>` with a numeric score, and the agent prompt only sees the winners.

### Upload flow

[`member_document_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/member_document_service.dart) is what the documents page calls. `pickAndExtract()` opens a file picker, extracts text (PDF via Syncfusion, plain text passed through), chunks it, embeds every chunk, saves to SQLite and Supabase, and reports progress via an `AttachProgress` state machine with `saving`, `embedding(current/total)`, `done`. Documents whose extracted text is shorter than 40 characters are rejected as probably-scanned images.

The health report PDF is also auto-attached to member documents on export, so the assistant can talk about its own past reports on the next turn without any manual step from the user.

---

## Family Analytics and Health Reports

Each family member has its own profile, its own scan history, its own uploaded documents, and its own dental analytics tally. Nothing about member A is exposed on member B's summary.

- The family list ([`family_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/family/family/family_widget.dart)) tallies sessions per member and uses a master-detail layout on tablets and desktop
- The member detail page has an in-line PDF export button
- The chat agent can address a specific member through `[NAV_MEMBER|Name]` and `[GET_MEMBER_LAST_SCAN|Name]`
- Deletes are gated by [`ConfirmDialog`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/dialogs/confirm_dialog.dart) with `isDestructive: true`

### Health report PDF

[`health_report_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/health_report_service.dart) is the export pipeline:

1. `buildPayload(memberId)` gathers the member profile and the last five sessions, along with image slices
2. Gemma is asked for a trend paragraph based on the aggregated findings
3. `syncfusion_flutter_pdf` composes the PDF with headers, tables, and embedded annotated images
4. A dialog shows working, then ready or error
5. On ready, `Printing.sharePdf()` opens the system share sheet
6. The PDF is fire-and-forget attached to the member's document store (so it is indexed by RAG for the next chat turn)

Filenames are sanitized to remove characters that break Android's share sheet.

---

## Design System

The Bina design system lives in [`lib/bina_design/`](https://github.com/vitrobiani/BinaApp/tree/main/lib/bina_design) and is layered above Material 3.

### Tokens

[`bina_design_tokens.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_design_tokens.dart) exposes:

| Token | Contents |
| --- | --- |
| `BinaColors` | Primary, ink, surface, `dxCavity`, `dxPlaque`, `gradHero`, semantic colours for diagnosis chips |
| `BinaSpace` | `s1` through `s10`, base-4 grid |
| `BinaRadius` | `xs=6`, `sm=10`, `md=14`, `lg=20`, `xl=28`, `pill=999` |
| `BinaElevation` | `sh1`..`sh4` and `shHero` |
| `BinaType` | Readex Pro for display, Inter for body, both via Google Fonts |
| `BinaMotion` | `d1`..`d4` motion durations for consistent animation |

### Themes

Five themes are shipped, defined in [`app_theme.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/app_core/app_theme.dart) and selected by [`app_theme_type.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/app_core/app_theme_type.dart):

| Theme | Intent |
| --- | --- |
| Light | Default day mode |
| Dark | Default night mode |
| Warm | Warmer palette for relaxed contexts |
| Cool | Cooler palette for clinical feel |
| Deuteranopia | Adjusted palette for red-green colour vision deficiency |

The profile page shows these as coloured swatches ([`main_profile_page_widget.dart:426`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/nav_pages/main_profile_page/main_profile_page_widget.dart#L426)).

### Responsive layout

[`bina_responsive.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_responsive.dart) declares three breakpoints:

| Breakpoint | Width |
| --- | --- |
| Phone | `<720 px` |
| Tablet | `720 px` to `1099 px` |
| Desktop | `>=1100 px` |

`BinaResponsive`, `BinaWidePage`, and `BinaMasterDetail` are the primitives that pages consume. The chrome switches from a 70 px floating pill nav on phones ([`bina_floating_nav.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_floating_nav.dart)) to a 236 px sidebar on desktop ([`bina_sidebar.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_sidebar.dart)).

### Shared components

- [`bina_components.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_components.dart) — `BinaButton` in `primary`, `secondary`, `ghost`, `coral`, `danger`, `glass`, `glassOutline` variants
- [`bina_progress_rings.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/bina_design/bina_progress_rings.dart) — Circular percentage rings for the home hero card
- [`confirm_dialog.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/dialogs/confirm_dialog.dart) — `ConfirmDialog.show(title, message, confirmText, cancelText, isDestructive, icon) → Future<bool>`
- [`loading_dialog.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/dialogs/loading_dialog.dart) — `LoadingDialog.show/hide/run<T>()` for one-line async gating
- [`gemma_download_progress_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/gemma_download_progress/gemma_download_progress_widget.dart) — Linear progress with status text and retry

---

## Accessibility, Nielsen Heuristics, Localization

Bina takes Nielsen's usability heuristics seriously. This section is grouped by heuristic to make the mapping explicit.

### Accessibility hub and text scaling

The accessibility hub ([`accessibility_widget.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/components/accessibility/accessibility_widget.dart)) is a single screen covering appearance (theme swatches, contrast slider), language, text size, guidance (hint mode), motion (reduce animations), and sensory (haptics). Dedicated pages under [`accessibility_pages/`](https://github.com/vitrobiani/BinaApp/tree/main/lib/pages/accessibility_pages) let you drill in.

[`accessibility_settings_service.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/services/accessibility_settings_service.dart) is a singleton `ChangeNotifier` that persists to `SharedPreferences`. Text scale is an enum:

| Scale | Multiplier |
| --- | --- |
| Small | 0.85 |
| Medium | 1.00 |
| Large | 1.15 |
| Extra Large | 1.30 |

Contrast is a slider between `-0.5` and `1.0`.

Age-based auto-adjust in [`text_scale.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/app_core/text_scale.dart) suggests defaults from the profile age:

| Age | Auto-suggested |
| --- | --- |
| 65+ | Large text, +0.3 contrast |
| 75+ | Extra-large text |

### Visibility of system status

- Camera scanning shows a live progress indicator with the current step ([`camera_connection_widget.dart:402`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/camera_connection/camera_connection_widget.dart#L402))
- Photo session shows a processing indicator when a shot is being analysed and a progress ring around the capture button
- Gemma model download shows a linear progress bar with byte counts and retry
- Document upload shows a three-stage `saving → embedding (x/y) → done` progress bar
- Session summary animates in an "Analyzing..." spinner before showing the Gemma paragraph

### Error prevention and confirmation

- Sign-out asks for confirmation ([`main_profile_page_widget.dart:54`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/nav_pages/main_profile_page/main_profile_page_widget.dart#L54))
- Delete member, delete session, and delete document all go through `ConfirmDialog` with `isDestructive: true`
- An in-progress scan session prompts before it is discarded
- Rejecting a document under 40 characters of extracted text prevents silently indexing empty PDFs

### Prevention of frustration

- The camera scanner auto-connects when it sees a `Bina` device rather than making the user tap
- When you enter calibration or diagnostics without a paired camera, a snackbar offers a direct redirect to the pairing screen ([`calibration_widget.dart:42`](https://github.com/vitrobiani/BinaApp/blob/main/lib/pages/other_pages/calibration/calibration_widget.dart#L42))
- The camera-not-found snackbar has a "Show all" action that widens the scanner to non-`Bina` devices for troubleshooting
- Ending a session with zero images prompts you rather than silently creating an empty record
- The uncovered-region warning at the end of a session tells you which mouth regions you missed so you can decide to keep scanning

### Localization

[`internationalization.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/app_core/internationalization.dart) is a static translation map covering four languages:

| Code | Language | Notes |
| --- | --- | --- |
| `en` | English | Default |
| `he` | Hebrew | RTL layout, tokenizer-aware punctuation for the sof pasuq |
| `id` | Indonesian | |
| `ms` | Malay | |

Hebrew triggers RTL directionality throughout the app. The Gemma agent also detects Hebrew per turn and instructs the model to reply in Hebrew even when the system prompt is English.

---

## State Management and Data Layer

- **AppState** is a `provider`-backed `ChangeNotifier` that holds the current session, active family member, camera connection, and cross-cutting flags
- **go_router** owns navigation; every navigation intent produced by the agent goes through it
- **SQLite** (`sqflite`) is the primary session store, chat store, and document store
- **Supabase** mirrors sessions and documents to the cloud and hosts pgvector for cloud RAG
- **Provider** wires `AppState` and `AppModel` into the widget tree

The dual-backend pattern (SQLite for offline speed, Supabase for cross-device sync and semantic search) shows up in `chunk_retriever.dart`, `member_document_service.dart`, and the family session tables. Both backends round-trip the same struct types generated under `lib/backend/schema/structs/`.

---

## Known Limitations

Honest inventory. These are the things worth calling out proactively to any reviewer:

- **Hebrew embedding quality**. EmbeddingGemma-300M's Hebrew retrieval is noticeably weaker than English. Chunk boundaries are also less reliable in Hebrew because our chunker only recognises the sof pasuq and standard punctuation, not the full range of taamim
- **Vague queries**. Gemma 3 1B in particular is easy to derail with vague follow-ups like "tell me more". The system prompt tries to steer it toward asking a clarifying question rather than confabulating, but it does not always
- **Passage budget is small**. The 1500-character reference block was chosen to protect 1B model quality; on 4 E2B it could safely be larger. Currently it is the same for both
- **Single-class YOLO**. The active detector is cavity-only. The multi-class labels are commented out in [`run_yolo_inference.dart`](https://github.com/vitrobiani/BinaApp/blob/main/lib/custom_code/actions/run_yolo_inference.dart) and there is no gingivitis or plaque detection today
- **iOS Gemma path**. GPU delegate for the YOLO detector is Android-only. The Gemma path itself runs on iOS through `flutter_gemma` but has not been performance-tuned there
- **Region estimator relies on calibration quality**. The 14-region default calibration is a reasonable starting point but per-user calibration is recommended, and skipped calibrations degrade the `uncoveredRegions` warning proportionally

---

## Suggested Additions

Space intentionally left for content to add before the presentation.

<details>
<summary>Architecture diagram</summary>

*(insert a high-level diagram showing phone, camera board, Supabase, and the ML pipeline)*

</details>

<details>
<summary>Entity-relationship diagram</summary>

*(insert an ERD covering `family_members`, `sessions`, `session_images`, `member_documents`, `document_chunks`, and their Supabase mirrors)*

</details>

<details>
<summary>Sequence diagram: scan session</summary>

*(insert a sequence diagram: user → camera pairing → calibration → photo session → YOLO tick → mouth region estimator → session summary → Gemma → session details / export)*

</details>

<details>
<summary>Sequence diagram: RAG chat turn</summary>

*(insert a sequence diagram: user query → language detection → EmbeddingGemma → chunk retrieval → system prompt build → Gemma → command parse → executor → follow-up Gemma turn → UI)*

</details>

<details>
<summary>Screenshots</summary>

*(insert screenshots for home, diagnostics with overlay, calibration, family list, member detail with PDF export, chat with RAG citation, accessibility hub)*

</details>
