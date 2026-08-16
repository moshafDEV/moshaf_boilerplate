import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/domain/entities/general_data_list/general_data_entity.dart';

class GeneralDataList extends StatelessWidget {
  final List<GeneralDataEntity> dataList;
  const GeneralDataList({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kMainWhite,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(color: kMainGreySoft, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var entry in dataList.asMap().entries)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: entry.key < dataList.length - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kMainGreySoft2, width: 1),
                      ),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    entry.value.label,
                    style: genStyle12Regular.copyWith(color: kMainSecondary),
                  ),
                  Text(
                    entry.value.value,
                    style: genStyle14Medium.copyWith(color: kMainPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
