import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import '../../radarr.dart';

class RadarrDetailsFiles extends StatefulWidget {
    final RadarrCatalogueData data;

    RadarrDetailsFiles({
        Key key,
        @required this.data,
    }) : super(key: key);

    @override
    State<RadarrDetailsFiles> createState() => _State();
}

class _State extends State<RadarrDetailsFiles> with AutomaticKeepAliveClientMixin {
    @override
    bool get wantKeepAlive => true;

    @override
    Widget build(BuildContext context) {
        super.build(context);
        return LSListView(
            children: <Widget>[widget.data.downloaded ? _entry : _empty],
            padBottom: true,
        );
    }

    Widget get _entry => LSCardTile(
        title: LSTitle(text: widget.data.movieFile['relativePath']),
        subtitle: RichText(
            text: TextSpan(
                style: TextStyle(
                    color: Colors.white70,
                ),
                children: widget.data.movieFile['mediaInfo'] != null
                    ? [
                        TextSpan(text: '${int.tryParse(widget.data.movieFile['size'].toString())?.lsBytes_BytesToString() ?? 'Unknown'}\t•\t'),
                        TextSpan(text: '${widget.data.movieFile['quality']['quality']['name'] ?? 'Unknown'}\t•\t'),
                        TextSpan(text: '${widget.data.movieFile['mediaInfo']['videoFormat'] ?? 'Unknown'}/'), 
                        TextSpan(text: '${widget.data.movieFile['mediaInfo']['audioFormat'] ?? 'Unknown'}'),
                    ]
                    : [
                        TextSpan(text: '${int.tryParse(widget.data.movieFile['size'].toString())?.lsBytes_BytesToString() ?? 'Unknown'}\t•\t'),
                        TextSpan(text: '${widget.data.movieFile['quality']['quality']['name'] ?? 'Unknown'}'),
                    ],
            ),
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
        ),
        trailing: LSIconButton(
            icon: Icons.delete,
            color: LSColors.red,
            onPressed: () async => _delete().catchError((_) {}),
        ),
    );

    Widget get _empty => LSGenericMessage(text: 'No Files Found');

    Future<void> _delete() async {
        List<dynamic> values = await RadarrDialogs.deleteMovieFile(context);
        RadarrAPI _api = RadarrAPI.from(Database.currentProfileObject);
        if(values[0]) _api.removeMovieFile(widget.data.movieFile['id'])
        .then((_) {
            LSSnackBar(
                context: context,
                title: 'Movie File Deleted',
                message: widget.data.movieFile['relativePath'],
                type: SNACKBAR_TYPE.success,
            );
            setState(() {
                widget.data.downloaded = false;
            });
        })
        .catchError((error) {
            LSSnackBar(
                context: context,
                title: 'Failed to Delete Movie File',
                message: Constants.CHECK_LOGS_MESSAGE,
                type: SNACKBAR_TYPE.failure,
            );
            return Future.error(error);
        });
    }
}
