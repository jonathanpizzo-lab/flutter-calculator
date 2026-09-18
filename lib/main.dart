import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jonathan Pizzo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff176b87),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _operators = {'+', '-', '*', '/'};
  static const _buttons = [
    ['7', '8', '9', '/'],
    ['4', '5', '6', '*'],
    ['1', '2', '3', '-'],
    ['C', '0', '=', '+'],
    ['x²'],
  ];

  final List<String> _tokens = [];
  String _display = '0';
  String _expression = '';
  bool _showingResult = false;

  bool _isOperator(String value) => _operators.contains(value);

  void _press(String value) {
    setState(() {
      if (value == 'C') {
        _clear();
      } else if (value == '=') {
        _calculate();
      } else if (value == 'x²') {
        _square();
      } else if (_isOperator(value)) {
        _addOperator(value);
      } else {
        _addDigit(value);
      }
    });
  }

  void _clear() {
    _tokens.clear();
    _expression = '';
    _display = '0';
    _showingResult = false;
  }

  void _addDigit(String digit) {
    if (_showingResult) {
      _tokens.clear();
      _expression = '';
      _showingResult = false;
    }
    if (_tokens.isEmpty || _isOperator(_tokens.last)) {
      _tokens.add(digit);
    } else {
      _tokens[_tokens.length - 1] += digit;
    }
    _expression = _tokens.join(' ');
    _display = _expression;
  }

  void _addOperator(String operator) {
    if (_tokens.isEmpty) return;
    if (_isOperator(_tokens.last)) {
      _tokens[_tokens.length - 1] = operator;
    } else {
      _tokens.add(operator);
    }
    _expression = _tokens.join(' ');
    _display = _expression;
    _showingResult = false;
  }

  void _calculate() {
    if (_tokens.isEmpty || _isOperator(_tokens.last)) return;
    try {
      final expression = _tokens.join(' ');
      final parsed = Expression.parse(expression);
      final value = const ExpressionEvaluator().eval(parsed, {});
      if (value is! num || !value.isFinite) {
        throw const FormatException('The result is not a finite number.');
      }
      _display = '$expression = ${_formatResult(value)}';
      _showingResult = true;
    } on Object {
      _display = '$_expression = Error';
      _showingResult = true;
    }
  }

  void _square() {
    if (_tokens.isEmpty || _isOperator(_tokens.last)) return;
    try {
      final parsed = Expression.parse(_tokens.join(' '));
      final value = const ExpressionEvaluator().eval(parsed, {});
      if (value is! num || !value.isFinite) {
        throw const FormatException('The result is not a finite number.');
      }
      final squared = value * value;
      final result = _formatResult(squared);
      _tokens
        ..clear()
        ..add(result);
      _expression = result;
      _display = result;
      _showingResult = true;
    } on Object {
      _display = '$_expression = Error';
      _showingResult = true;
    }
  }

  String _formatResult(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xfff3f7f8),
      appBar: AppBar(
        title: const Text('Jonathan Pizzo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Text(
                          _display,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final row in _buttons)
                        for (final value in row)
                          _CalculatorButton(
                            label: value,
                            isOperator: _isOperator(value),
                            isClear: value == 'C',
                            onPressed: () => _press(value),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.onPressed,
    this.isOperator = false,
    this.isClear = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isClear
        ? colors.errorContainer
        : isOperator
        ? colors.primaryContainer
        : colors.surface;
    final foreground = isClear ? colors.onErrorContainer : colors.onSurface;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
    );
  }
}
