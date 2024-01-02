import 'package:flutter/material.dart' hide DateUtils;
import 'package:todo_list/utils/date_utils.dart';
import 'package:todo_list/utils/default_values.dart';

class DateInputField extends StatelessWidget {
  final String? title;
  final DateTime? value;
  final void Function(DateTime)? onChanged;

  const DateInputField({Key? key, this.title, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isNull = value == null;
    selectDate() async {
      final DateTime? picked = await DateUtils.selectDateTime(context);
      if (picked != null) {
        onChanged?.call(picked);
      }
    }

    return GestureDetector(
      onTap: selectDate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: DefaultValues.gap)
          ],
          Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ))),
              child: Row(
                children: [
                  Text(
                    !isNull
                        ? DateUtils.getFormattedDate(value)
                        : "----.--.-- AM/PM --:--",
                    style: TextStyle(
                      fontSize: DefaultValues.fontSize,
                      color: isNull
                          ? Theme.of(context).hintColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_month_sharp,
                    size: 24,
                  )
                ],
              )),
        ],
      ),
    );
  }
}
