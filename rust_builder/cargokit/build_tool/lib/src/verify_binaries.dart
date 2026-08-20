/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:ed25519_edwards/ed25519_edwards.dart';
import 'package:http/http.dart';

import 'artifacts_provider.dart';
import 'cargo.dart';
import 'crate_hash.dart';
import 'options.dart';
import 'precompile_binaries.dart';
import 'target.dart';

class VerifyBinaries {
  VerifyBinaries({
    required this.manifestDir,
  });

  final String manifestDir;

  Future<void> run() async {
    try {
      stdout.writeln('开始验证二进制文件，清单目录: $manifestDir');
      final crateInfo = CrateInfo.load(manifestDir);
      stdout.writeln('加载的包名: ${crateInfo.packageName}');

      final config = CargokitCrateOptions.load(manifestDir: manifestDir);
      final precompiledBinaries = config.precompiledBinaries;
      if (precompiledBinaries == null) {
        stdout.writeln('Crate does not support precompiled binaries.');
      } else {
        final crateHash = CrateHash.compute(manifestDir);
        stdout.writeln('Crate hash: $crateHash');

        for (final target in Target.all) {
          final message = 'Checking ${target.rust}...';
          stdout.write(message.padRight(40));
          stdout.flush();

          final artifacts = getArtifactNames(
            target: target,
            libraryName: crateInfo.packageName,
            remote: true,
          );
          
          stdout.writeln('目标 ${target.rust} 的构件: ${artifacts.join(", ")}');

          final prefix = precompiledBinaries.uriPrefix;

          bool ok = true;

          for (final artifact in artifacts) {
            final fileName = PrecompileBinaries.fileName(target, artifact);
            final signatureFileName =
                PrecompileBinaries.signatureFileName(target, artifact);

            final url = Uri.parse('$prefix$crateHash/$fileName');
            final signatureUrl =
                Uri.parse('$prefix$crateHash/$signatureFileName');

            stdout.writeln('检查文件: $url');
            stdout.writeln('检查签名: $signatureUrl');

            try {
              final signature = await get(signatureUrl);
              if (signature.statusCode != 200) {
                stdout.writeln('MISSING (状态码: ${signature.statusCode})');
                stdout.writeln('签名文件不存在或无法访问: $signatureUrl');
                ok = false;
                break;
              }
              
              final asset = await get(url);
              if (asset.statusCode != 200) {
                stdout.writeln('MISSING (状态码: ${asset.statusCode})');
                stdout.writeln('构件文件不存在或无法访问: $url');
                ok = false;
                break;
              }

              if (!verify(precompiledBinaries.publicKey, asset.bodyBytes,
                  signature.bodyBytes)) {
                stdout.writeln('INVALID SIGNATURE');
                stdout.writeln('签名验证失败，可能是公钥不匹配或文件已被修改');
                ok = false;
              }
            } catch (e) {
              stdout.writeln('ERROR: $e');
              ok = false;
              break;
            }
          }

          if (ok) {
            stdout.writeln('OK');
          } else {
            stdout.writeln('验证失败，将尝试本地编译');
          }
        }
      }
    } catch (e, stackTrace) {
      stdout.writeln('验证二进制文件时发生错误: $e');
      stdout.writeln('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
