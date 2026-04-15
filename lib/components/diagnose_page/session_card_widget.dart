import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_card_model.dart';
export 'session_card_model.dart';

class SessionCardWidget extends StatefulWidget {
  const SessionCardWidget({
    super.key,
    required this.sessionDate,
    required this.findings,
    required this.overallStatus,
    required this.onTap,
  });

  final DateTime? sessionDate;
  final String? findings;
  final String? overallStatus;
  final Future<void> Function() onTap;

  @override
  State<SessionCardWidget> createState() => _SessionCardWidgetState();
}

class _SessionCardWidgetState extends State<SessionCardWidget> {
  late SessionCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SessionCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 3.0,
                color: Color(0x20000000),
                offset: Offset(
                  0.0,
                  1.0,
                ),
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
                    width: 70.0,
                    height: 70.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                        child: Text(
                          widget.overallStatus!,
                          style: AppTheme.of(context).titleMedium.override(
                                fontFamily: 'Readex Pro',
                                color: AppTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 0.0, 0.0),
                        child: Text(
                          dateTimeFormat('d/M/y', widget.sessionDate),
                          style: AppTheme.of(context).bodySmall.override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 0.0, 0.0),
                        child: Text(
                          widget.findings!,
                          style: AppTheme.of(context).bodySmall.override(
                                fontFamily: 'Inter',
                                color: AppTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.of(context).secondaryText,
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
