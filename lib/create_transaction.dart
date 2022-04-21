import 'package:flutter/material.dart';
import 'package:pcsdk_demo/api_helper.dart';
import 'package:pcsdk_demo/transaction_data.dart';
import 'package:pcsdk/models/pcuser.dart';
import 'package:pcsdk/models/pctransaction.dart';
import 'package:pcsdk/pctransactionsmanager.dart';

class CreateTransaction extends StatefulWidget {
  final PCUser user;
  const CreateTransaction({Key? key, required this.user}) : super(key: key);

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  final _formKey = GlobalKey<FormState>();

  final accountController = TextEditingController();
  final amountController = TextEditingController();
  final commentsController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    accountController.dispose();
    amountController.dispose();
    commentsController.dispose();
    super.dispose();
  }

  Future showTransaction(Future<PCTransaction> transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TransactionData(title: 'Transaction', user: widget.user, transaction: transaction)),
    );
  }

  Future createTransaction() async {
    /**
     * 1. Creating transaction
     *
     * =========================================
     * [WARNING] DO NOT USE IN PRODUCTION BUILDS
     * =========================================
     *
     * Transaction data should be sent to Application back-end.
     * And PC transaction should be created by Appliction back-end via
     * PC Server's API
     *
     * see PC docs for proper using scenario
     * https://repo.payconfirm.org/server/doc/v5.3/arch_and_principles/#document-signing-flow
     *
     */ 
    String commentsText = commentsController.text.isEmpty ? "" : "\n\nComments:\n\n${commentsController.text}";
    String transactionID = await APIHelper.createTransaction(
        '# Transfer to ${accountController.text}\n**Amount:** ${amountController.text}${commentsText}',
        widget.user.userId);

    // 2. Downloading transaction
    Future<PCTransaction> futureTransaction = PCTransactionsManager.getTransaction(transactionID, widget.user);

    // 3. Processing transaction
    await showTransaction(futureTransaction);

    // 4. Clearing data
    accountController.clear();
    amountController.clear();
    commentsController.clear();

    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget renderBody() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'New Transfer',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextFormField(
                controller: accountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field should\'n be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter beneficiary account',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextFormField(
                controller: amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field should\'n be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter amount',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextFormField(
                controller: commentsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter comments (Optional)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createTransaction();
                    }
                  },
                  child: const Text('Transfer'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16))),
            ),
            const Spacer(flex: 2),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0x00000000),
        ),
        extendBodyBehindAppBar: true,
        body: renderBody());
  }
}
