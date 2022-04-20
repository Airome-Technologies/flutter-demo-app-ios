import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:pcsdk/models/pcresult.dart';
import 'package:pcsdk/models/pcuser.dart';
import 'package:pcsdk/models/pctransaction.dart';
import 'package:pcsdk/pctransactionsmanager.dart';
import 'package:pcsdk/pcusersmanager.dart';
import 'package:pcsdk_demo/consts.dart';

class TransactionData extends StatefulWidget {
  final String title;
  final PCUser user;
  final Future<PCTransaction> transaction;
  const TransactionData({Key? key, required this.title, required this.user, required this.transaction})
      : super(key: key);

  @override
  State<TransactionData> createState() => _TransactionDataState();
}

class _TransactionDataState extends State<TransactionData> {
  void showAlert(String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  Future confirmTransaction() async {
    String title, message;
    try {
      await PCUsersManager.submitPassword(widget.user, Consts.commonPassword);
      PCTransaction transaction = await widget.transaction;
      List<PCResult> results = await PCTransactionsManager.sign([transaction], widget.user);

      debugPrint('Results ${results.toString()}');

      title = 'Done';
      message = 'Successfully confirmed';
    } catch (e) {
      title = 'Error';
      message = e.toString();
    }

    showAlert(title, message);
  }

  Future declineTransaction() async {
    String title, message;
    try {
      await PCUsersManager.submitPassword(widget.user, Consts.commonPassword);
      PCTransaction transaction = await widget.transaction;
      List<PCResult> results = await PCTransactionsManager.decline([transaction], widget.user);

      debugPrint('Results ${results.toString()}');

      title = 'Done';
      message = 'Successfully declined';
    } catch (e) {
      title = 'Error';
      message = e.toString();
    }

    showAlert(title, message);
  }

  Widget makeButtons() => Row(
        children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    confirmTransaction();
                  },
                  child: const Text('Confirm'))),
          const SizedBox(
            width: 16.0,
          ),
          Expanded(
              child: OutlinedButton(
            onPressed: () {
              declineTransaction();
            },
            child: const Text('Decline'),
            style: OutlinedButton.styleFrom(
              primary: Colors.red, // foreground
            ),
          )),
        ],
      );

  Widget makeBody() => SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Stack(
        children: [
          FutureBuilder(
              future: widget.transaction,
              builder: (BuildContext context, AsyncSnapshot<PCTransaction> snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data?.transactionContent?.text ?? 'No text',
                    styleSheet: MarkdownStyleSheet(
                        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        p: const TextStyle(fontSize: 16)),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
          Align(alignment: Alignment.bottomCenter, child: makeButtons()),
        ],
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: makeBody(),
      );
}
