import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //Note: you need to handle these on state clears because otherwise they stick in memory and cause memory leaks.
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  //usually we don't need controllers for froms since Form() handles it for us, BUT if you want access to some info before the form is submitted, like we will with the image preview feature, THEN its good to use a controller where needed.
  final _imageUrlController = TextEditingController();

  //this function is for whenever the user focus changes (they click nearly anywhere) the image preview will update and show the image, needed to fix a bug.
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {
        //do nothing
      });
    }
  }

//needed to help with bug from the image preview feature, adds a listen so when we break focus from entering the URL it will actually update the UI and show.
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  //use a dispose method to do the clean up:
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      //Form is a helper widget to quickly add validation, user feedback features, and other helpful features.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          //nearly alwasy use SingleChildScrollView and Column for forms, if you do listView and the app scroll or is in landscope mode, users can lose input fields because of how the ui builds and deletes widgets based on viwes. Doing it this ways prevents that.
          child: SingleChildScrollView(
            child: Column(
              children: [
                //a special ersion of TextField that's specialized for Forms.
                TextFormField(
                  //MANY decorations options, look to offical docs for more.
                  decoration: InputDecoration(labelText: 'Title'),
                  //the part to submit or confirm what you wrote in the text area, using .next makes the soft keyboard know to jump to the next input instead of submitting the entire form
                  textInputAction: TextInputAction.next,
                  //this is what is fired when the submit button on the soft keyboard is pressed, usese the focus node to jump to the next textField I want, in this case price.
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  //make the keyboard a num pad.
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  keyboardType: TextInputType.multiline,
                  //multipline automatically includes textInputAction: TextInputAction.next feature and thus we can't use onFieldSubmit for this either.
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 10),
                      //reminder the only way to decorate a container with things like background and borders is with BoxDecoration
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter a URL')
                          : FittedBox(
                              child: Image.network(_imageUrlController.text),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        //doing .done is what you use to submit the ENTIRE form, so make sure its last.
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
