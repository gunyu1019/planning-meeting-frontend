import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';

class AssistantMessageComponent extends SimpleTextMessage {
  const AssistantMessageComponent({
    super.key,
    required super.message,
    required super.index,
  });

  bool get _isOnlyEmoji => message.metadata?['isOnlyEmoji'] == true;

  @override
  Widget build(BuildContext context) {
    final theme = context.select(
      (ChatTheme t) => (
        labelSmall: t.typography.labelSmall,
        onPrimary: t.colors.onPrimary,
        onSurface: t.colors.onSurface,
        primary: t.colors.primary,
        shape: t.shape,
        surfaceContainer: t.colors.surfaceContainer,
      ),
    );
    final isSentByMe = context.read<UserID>() == message.authorId;
    final backgroundColor = isSentByMe ? theme.primary : theme.surfaceContainer;
    final textColor = isSentByMe ? theme.onPrimary : theme.onSurface;
    final timeStyle = isSentByMe
        ? theme.labelSmall.copyWith(color: theme.onPrimary)
        : theme.labelSmall.copyWith(color: theme.onSurface);

    final timeAndStatus = showTime || (isSentByMe && showStatus)
        ? TimeAndStatus(
            time: message.resolvedTime,
            status: message.resolvedStatus,
            showTime: showTime,
            showStatus: isSentByMe && showStatus,
            textStyle: timeStyle,
          )
        : null;

    final themeData = Theme.of(context);
    final textContent = MarkdownBody(
      data: message.text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        a: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
        p: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
        h1: themeData.textTheme.headlineSmall?.copyWith(color: textColor),
        h2: themeData.textTheme.titleLarge?.copyWith(color: textColor),
        h3: themeData.textTheme.titleMedium?.copyWith(color: textColor),
        h4: themeData.textTheme.bodyLarge?.copyWith(color: textColor),
        h5: themeData.textTheme.bodyLarge?.copyWith(color: textColor),
        h6: themeData.textTheme.bodyLarge?.copyWith(color: textColor),
        tableBody: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
        listBullet: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
        blockquote: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
        em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
        strong: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        del: TextStyle(
          decoration: TextDecoration.lineThrough,
          color: textColor,
        ),
        img: themeData.textTheme.bodyMedium?.copyWith(color: textColor),
      ),
    );

    final linkPreviewWidget = linkPreviewPosition != LinkPreviewPosition.none
        ? context.read<Builders>().linkPreviewBuilder?.call(
            context,
            message,
            isSentByMe,
          )
        : null;

    return ClipRRect(
      borderRadius: theme.shape,
      child: Container(
        constraints: constraints,
        decoration: _isOnlyEmoji ? null : BoxDecoration(color: backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: _isOnlyEmoji
                  ? EdgeInsets.symmetric(
                      horizontal: (padding?.horizontal ?? 0) / 2,
                      vertical: 0,
                    )
                  : padding,
              child: _buildContentBasedOnPosition(
                context: context,
                textContent: textContent,
                timeAndStatus: timeAndStatus,
                linkPreviewWidget: linkPreviewWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBasedOnPosition({
    required BuildContext context,
    required Widget textContent,
    TimeAndStatus? timeAndStatus,
    Widget? linkPreviewWidget,
  }) {
    final textDirection = Directionality.of(context);
    final effectiveLinkPreviewPosition = linkPreviewWidget != null
        ? linkPreviewPosition
        : LinkPreviewPosition.none;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topWidget != null) topWidget!,
            if (effectiveLinkPreviewPosition == LinkPreviewPosition.top)
              linkPreviewWidget!,
            timeAndStatusPosition == TimeAndStatusPosition.inline
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(child: textContent),
                      SizedBox(width: 4),
                      Padding(padding: EdgeInsets.zero, child: timeAndStatus),
                    ],
                  )
                : textContent,
            if (effectiveLinkPreviewPosition == LinkPreviewPosition.bottom)
              linkPreviewWidget!,
            if (timeAndStatusPosition != TimeAndStatusPosition.inline)
              // Ensure the  width is not smaller than the timeAndStatus widget
              // Ensure the height accounts for it's height
              Opacity(opacity: 0, child: timeAndStatus),
          ],
        ),
        if (timeAndStatusPosition != TimeAndStatusPosition.inline &&
            timeAndStatus != null)
          Positioned.directional(
            textDirection: textDirection,
            end: timeAndStatusPosition == TimeAndStatusPosition.end ? 0 : null,
            start: timeAndStatusPosition == TimeAndStatusPosition.start
                ? 0
                : null,
            bottom: 0,
            child: timeAndStatus,
          ),
      ],
    );
  }
}
