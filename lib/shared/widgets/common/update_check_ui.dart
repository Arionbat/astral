import 'package:astral/core/services/update_downloader.dart';
import 'package:astral/core/services/update_service.dart';
import 'package:astral/shared/widgets/common/update_dialogs.dart';
import 'package:astral/shared/widgets/common/update_download_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 更新检查 UI 编排（对话框）
class UpdateCheckUi {
  const UpdateCheckUi._();

  static final _downloader = UpdateDownloader();

  static Future<void> checkAndPresent(
    BuildContext context,
    UpdateChecker checker, {
    bool showNoUpdateMessage = true,
    bool forceShowDownload = false,
    bool showFailureMessage = true,
  }) async {
    // 用户主动点击时立刻给进度反馈；静默自动检查不挡启动界面
    final showBusy = showNoUpdateMessage || forceShowDownload;
    BuildContext? busyContext;

    if (showBusy && context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          busyContext = dialogContext;
          return const UpdateBusyDialog(
            title: '检查更新',
            message: '正在从 GitHub 获取版本信息…',
          );
        },
      );
    }

    final result = await checker.check(
      forceShowDownload: forceShowDownload,
      showNoUpdateMessage: showNoUpdateMessage,
      showFailureMessage: showFailureMessage,
    );

    if (busyContext != null && busyContext!.mounted) {
      Navigator.of(busyContext!).pop();
    }

    if (!context.mounted || result == null) return;
    _showDialog(context, result);
  }

  static void _showDialog(BuildContext context, UpdateCheckResult result) {
    final parentContext = context;
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder:
          (dialogContext) => UpdateDialog(
            version: result.version,
            releaseNotes: result.releaseNotes,
            downloadUrl: result.releasePage,
            isLatestVersion: result.isLatestVersion,
            releaseInfo: result.releaseInfo,
            onDownload:
                result.releaseInfo != null
                    ? () => UpdateDownloadUi.handleDownload(
                      parentContext,
                      result.releaseInfo!,
                      _downloader,
                    )
                    : null,
            onNetDiskDownload:
                result.releaseInfo != null
                    ? () => openNetDiskDownload(parentContext)
                    : null,
          ),
    );
  }

  static Future<void> openNetDiskDownload(BuildContext context) async {
    final uri = Uri.parse(
      'https://astral.fan/quick-start/download-install/',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
