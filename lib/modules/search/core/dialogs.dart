import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';

class SearchDialogs {
    SearchDialogs._();
    
    static Future<List<dynamic>> downloadResult(BuildContext context) async {
        bool _flag = false;
        String _service = '';

        void _setValues(bool flag, String service) {
            _flag = flag;
            _service = service;
            Navigator.of(context).pop();
        }

        await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: LSDialog.title(text: 'Download'),
                actions: <Widget>[
                    LSDialog.cancel(context, textColor: LSColors.accent),
                ],
                content: ValueListenableBuilder(
                    valueListenable: Database.lunaSeaBox.listenable(keys: [LunaSeaDatabaseValue.ENABLED_PROFILE.key]),
                    builder: (context, lunaBox, widget) => ValueListenableBuilder(
                        valueListenable: Database.profilesBox.listenable(),
                        builder: (context, profilesBox, widget) => LSDialog.content(
                            children: <Widget>[
                                Padding(
                                    child: DropdownButton(
                                        icon: LSIcon(
                                            icon: Icons.arrow_drop_down,
                                            color: LSColors.accent,
                                        ),
                                        underline: Container(
                                            height: 2,
                                            color: LSColors.accent,
                                        ),
                                        value: lunaBox.get(LunaSeaDatabaseValue.ENABLED_PROFILE.key),
                                        items: (profilesBox as Box).keys.map<DropdownMenuItem<String>>((dynamic value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                        )).toList(),
                                        onChanged: (value) {
                                            lunaBox.put(LunaSeaDatabaseValue.ENABLED_PROFILE.key, value);
                                        },
                                        isExpanded: true,
                                    ),
                                    padding: EdgeInsets.fromLTRB(36.0, 0.0, 12.0, 16.0),
                                ),
                                if(Database.currentProfileObject.sabnzbdEnabled) LSDialog.tile(
                                    icon: CustomIcons.sabnzbd,
                                    iconColor: LSColors.list(0),
                                    text: 'SABnzbd',
                                    onTap: () => _setValues(true, 'sabnzbd'),
                                ),
                                if(Database.currentProfileObject.nzbgetEnabled) LSDialog.tile(
                                    icon: CustomIcons.nzbget,
                                    iconColor: LSColors.list(1),
                                    text: 'NZBGet',
                                    onTap: () => _setValues(true, 'nzbget'),
                                ),
                                LSDialog.tile(
                                    icon: Icons.file_download,
                                    iconColor: LSColors.list(2),
                                    text: 'Download to Device',
                                    onTap: () => _setValues(true, 'filesystem'),
                                ),
                            ],
                        ),
                    ),
                ),
                contentPadding: EdgeInsets.fromLTRB(0.0, 26.0, 24.0, 0.0),
                shape: LSDialog.shape(),
            ),
        );
        return [_flag, _service];
    }
}
