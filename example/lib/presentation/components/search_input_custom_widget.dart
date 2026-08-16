import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:example/core/constants/assets.gen.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';

class SearchInputCustomWidget extends StatelessWidget {
  final TextEditingController fieldController;
  final bool isPassword;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final String? invalidMessage;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;

  const SearchInputCustomWidget({
    super.key,
    required this.fieldController,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.isPassword = false,
    this.isReadOnly = false,
    this.textInputAction = TextInputAction.done,
    this.invalidMessage,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchInputStateless(
          labelText: labelText,
          fieldController: fieldController,
          isPassword: isPassword,
          hintText: hintText,
          keyboardType: keyboardType,
          isReadOnly: isReadOnly,
          onChanged: onChanged,
          validator: validator,
          textInputAction: textInputAction,
          useErrorBorder: invalidMessage != null,
          errorText: invalidMessage,
        ),
      ],
    );
  }
}

class _SearchInputStateless extends StatefulWidget {
  final TextEditingController fieldController;
  final bool isPassword;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final bool useErrorBorder;
  final String? errorText;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;

  const _SearchInputStateless({
    required this.fieldController,
    required this.isPassword,
    this.hintText = 'Search...',
    required this.labelText,
    required this.keyboardType,
    required this.isReadOnly,
    this.textInputAction = TextInputAction.done,
    this.useErrorBorder = false,
    this.errorText,
    this.onChanged,
    this.validator,
  });

  @override
  State<_SearchInputStateless> createState() => _SearchInputStatelessState();
}

class _SearchInputStatelessState extends State<_SearchInputStateless> {
  @override
  void initState() {
    super.initState();
    widget.fieldController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.fieldController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: widget.fieldController,
      hintText: widget.hintText,
      textStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.focused) ||
            widget.fieldController.text.isNotEmpty) {
          return genStyle14Regular;
        }
        return genStyle14Regular.copyWith(color: kMainSecondary);
      }),
      shadowColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
      shape: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.focused)) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kMainBlue, width: 1.5),
          );
        }
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kMainGreySoft, width: 1),
        );
      }),
      keyboardType: widget.keyboardType,
      constraints: const BoxConstraints(minHeight: 45, maxHeight: 45),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 10),
      ),
      onTap: () {
        // controller.openView();
      },
      onChanged: (val) {
        widget.onChanged?.call(val);
      },
      leading: SvgPicture.asset(
        Assets.svg.iconSearch,
        width: 20,
        height: 20,
      ),
      trailing: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.fieldController,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () {
                widget.fieldController.clear();
                widget.onChanged?.call('');
              },
              child: const Icon(Icons.close, size: 18, color: kMainSecondary),
            );
          },
        ),
      ],
    );
  }
}
