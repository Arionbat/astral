import 'package:astral/features/rooms/widgets/peer_connection_style.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 列表模式：单行紧凑项
class ListUserCard extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4;
  final bool showDivider;

  const ListUserCard({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
    this.showDivider = true,
  });

  @override
  State<ListUserCard> createState() => _ListUserCardState();
}

class _ListUserCardState extends State<ListUserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final localIPv4 = widget.localIPv4 ?? '';
    final player = widget.player;
    final colorScheme = widget.colorScheme;
    final displayName =
        player.hostname.startsWith('PublicServer_')
            ? player.hostname.substring('PublicServer_'.length)
            : player.hostname;
    final connectionType = PeerConnectionStyle.mapConnectionType(
      player.cost,
      player.ipv4,
      localIPv4,
    );
    final connectionTypeColor = PeerConnectionStyle.getConnectionTypeColor(
      connectionType,
      colorScheme,
    );
    final latencyColor = PeerConnectionStyle.getLatencyColor(player.latencyMs);
    final lossColor = PeerConnectionStyle.getPacketLossColor(player.lossRate);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Material(
        color:
            isHovered
                ? colorScheme.primary.withValues(alpha: 0.06)
                : Colors.transparent,
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: player.ipv4));
            AppSnackBars.success(
              context,
              '已复制',
              'IP地址: ${player.ipv4}',
              duration: const Duration(seconds: 2),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border:
                  widget.showDivider
                      ? Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      )
                      : null,
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: connectionTypeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    connectionType,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                if (connectionType != '本机') ...[
                  const SizedBox(width: 8),
                  Text(
                    '${player.latencyMs.toStringAsFixed(0)}ms',
                    style: TextStyle(
                      color: latencyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${player.lossRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: lossColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (player.ipv4 != '' && player.ipv4 != '0.0.0.0') ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      player.ipv4,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
