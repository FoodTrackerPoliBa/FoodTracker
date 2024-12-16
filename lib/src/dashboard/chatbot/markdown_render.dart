import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownRender extends StatelessWidget {
  final String data;
  final Color? textColor;
  const MarkdownRender({super.key, required this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      selectable: true,
      data: data,
      builders: {
        'latex': LatexElementBuilder(
          textStyle:
              TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          onErrorFallback: (except, text) {
            return Text(text);
          },
        ),
      },
      extensionSet: md.ExtensionSet(
        [LatexBlockSyntax()],
        [LatexInlineSyntax()],
      ),
      styleSheet: MarkdownStyleSheet(
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          code: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          blockquoteDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          blockquote: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          h1: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          h2: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          h3: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          h4: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          h5: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          listBullet: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          p: TextStyle(
            color: textColor ?? Theme.of(context).colorScheme.onPrimary,
          )),
    );
  }
}
