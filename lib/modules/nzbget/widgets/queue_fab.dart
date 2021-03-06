import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:tuple/tuple.dart';
import '../../nzbget.dart';

class NZBGetQueueFAB extends StatelessWidget {
    @override
    Widget build(BuildContext context) => Selector<NZBGetModel, Tuple2<bool, bool>>(
        selector: (_, model) => Tuple2(model.error, model.paused),
        builder: (context, data, _) => data.item1
            ? Container()
            : InkWell(
                child: LSFloatingActionButton(
                    icon: data.item2 ? Icons.play_arrow : Icons.pause,
                    onPressed: () => _toggle(context, data.item2),
                ),
                onLongPress: () => _toggleFor(context),
                borderRadius: BorderRadius.circular(28.0),
            ),
    );

    Future<void> _toggle(BuildContext context, bool paused) async {
        NZBGetAPI _api = NZBGetAPI.from(Database.currentProfileObject);
        paused
            ? _resume(context, _api)
            : _pause(context, _api);
    }

    Future<void> _toggleFor(BuildContext context) async {
        List values = await NZBGetDialogs.pauseFor(context);
        if(values[0]) {
            if(values[1] == -1) {
                List values = await NZBGetDialogs.customPauseFor(context);
                if(values[0]) await NZBGetAPI.from(Database.currentProfileObject).pauseQueueFor(values[1])
                .then((_) => LSSnackBar(
                    context: context,
                    title: 'Pausing Queue',
                    message: 'For ${(values[1] as int).lsTime_durationString(multiplier: 60)}',
                    type: SNACKBAR_TYPE.success,
                ))
                .catchError((_) => LSSnackBar(
                    context: context,
                    title: 'Failed to Pause Queue',
                    message: Constants.CHECK_LOGS_MESSAGE,
                    type: SNACKBAR_TYPE.failure,
                ));
            } else {
                await NZBGetAPI.from(Database.currentProfileObject).pauseQueueFor(values[1])
                .then((_) => LSSnackBar(
                    context: context,
                    title: 'Pausing Queue',
                    message: 'For ${(values[1] as int).lsTime_durationString(multiplier: 60)}',
                    type: SNACKBAR_TYPE.success,
                ))
                .catchError((_) => LSSnackBar(
                    context: context,
                    title: 'Failed to Pause Queue',
                    message: Constants.CHECK_LOGS_MESSAGE,
                    type: SNACKBAR_TYPE.failure,
                ));
            }
        }
    }

    Future<void> _pause(BuildContext context, NZBGetAPI api) async {
        await api.pauseQueue()
        .then((_) {
            Provider.of<NZBGetModel>(context, listen: false).paused = true;
        })
        .catchError((_) => LSSnackBar(
            context: context,
            title: 'Failed to Pause Queue',
            message: Constants.CHECK_LOGS_MESSAGE,
            type: SNACKBAR_TYPE.failure,
        ));
    }

    Future<void> _resume(BuildContext context, NZBGetAPI api) async {
        return await api.resumeQueue()
        .then((_) {
            Provider.of<NZBGetModel>(context, listen: false).paused = false;
        })
        .catchError((_) => LSSnackBar(
            context: context,
            title: 'Failed to Resume Queue',
            message: Constants.CHECK_LOGS_MESSAGE,
            type: SNACKBAR_TYPE.failure,
        ));
    }
}
