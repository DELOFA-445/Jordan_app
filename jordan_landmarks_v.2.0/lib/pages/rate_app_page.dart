import 'package:flutter/material.dart';
import '../viewmodels/rate_app_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';

class RateAppPage extends StatefulWidget {
  RateAppPage({super.key});

  @override
  State<RateAppPage> createState() {
    return _RateAppPageState();
  }
}

class _RateAppPageState extends State<RateAppPage> {
  RateAppViewModel vm = RateAppViewModel();

  @override
  void initState() {
    super.initState();
    vm.addListener(updateVm);
  }

  void updateVm() {
    setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(updateVm);
    vm.dispose();
    super.dispose();
  }

  void submitRating() async {
    var english = settingsViewModel.isEnglish;

    if (vm.rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.get('choose_rating', english),
          ),
        ),
      );
      return;
    }

    var confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.get('save_data', english),
          ),
          content: Text(
            AppLocalizations.get('save_dialog_desc', english),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                AppLocalizations.get('cancel', english),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.get('agree', english),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await vm.saveRating();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.get('rating_saved', english),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    List<Widget> stars = [];
    for (var i = 1; i <= 5; i++) {
      stars.add(
        GestureDetector(
          onTap: () {
            vm.setRating(i);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              i <= vm.rating ? Icons.star : Icons.star_border,
              size: 48,
              color: i <= vm.rating ? Colors.amber : Colors.grey,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('rate_app', english),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.rate_review, size: 64, color: Colors.brown),
              SizedBox(height: 16),
              Text(
                AppLocalizations.get('rate_question', english),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: stars,
              ),
              SizedBox(height: 8),
              Text(
                vm.rating > 0 ? vm.rating.toString() + ' / 5' : '',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 32),
              TextField(
                controller: vm.commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('comment_hint', english),
                  hintText: '...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    AppLocalizations.get('submit_rating', english),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
