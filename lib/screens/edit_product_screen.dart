import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  //this is a global key; its used to access data/state from inside my widget below, 99% of time its for Forms.
  final _form = GlobalKey<FormState>();
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

  _saveForm() {
    //trigger all the validators in the textformfields and will return true they all pass, and return false if any validator has a string, aka error.
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return; //aka don't run rest of saveForm code.
    }
    //running .save will trigger the onSaved method on every textformfield, allowing me to take the value in those fields and do whatever I want. like putting it in a map or list.
    _form.currentState.save();
    Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    Navigator.of(context).pop();
    // print(_editedProduct.id);
    // print(_editedProduct.title);
    // print(_editedProduct.price);
    // print(_editedProduct.description);
    // print(_editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      //Form is a helper widget to quickly add validation, user feedback features, and other helpful features.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          //nearly alwasy use SingleChildScrollView and Column for forms, if you do listView and the app scroll or is in landscope mode, users can lose input fields because of how the ui builds and deletes widgets based on viwes. Doing it this ways prevents that.
          child: SingleChildScrollView(
            child: Column(
              children: [
                //a special ersion of TextField that's specialized for Forms.
                TextFormField(
                  //MANY decorations options, look to offical docs for more.
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  //the part to submit or confirm what you wrote in the text area, using .next makes the soft keyboard know to jump to the next input instead of submitting the entire form
                  textInputAction: TextInputAction.next,
                  //this is what is fired when the submit button on the soft keyboard is pressed, usese the focus node to jump to the next textField I want, in this case price.
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  //the value is whatever string is in the TextFormField, the validator is called when you tell a validate method of if the form has auto-validate true (which executes on every keystroke).
                  //return null = input is correct, return string = the error text you want to show the user. You configure how the error message looks in the decoration method with errorStyle or a default errorText.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Provide a Value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //need to make a new Product instance becasue we use final word for product attritbutes, this is not a big deal since we just overwrite the one field we care about and copy the rest back/
                    //alternatively I could make a new class just for submitting form data, that has mutiple properties instead of final. a bit more performant but not a deal breaker.
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        title: value,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter a price.';
                    }
                    //tryParse will not fail/throw an error (like just parse), it will simply return null on failure.
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    //since we passed tryParse already, we know this parse can't fail/error out.
                    if (double.parse(value) <= 0) {
                      return 'Please enter a number greater than zero.';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  //make the keyboard a num pad.
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        price: double.parse(value),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter a description';
                    }
                    if (value.length < 10) {
                      return 'should be at least 10 characters long';
                    }
                    return null;
                  },
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  keyboardType: TextInputType.multiline,
                  //multipline automatically includes textInputAction: TextInputAction.next feature and thus we can't use onFieldSubmit for this either.
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: value,
                        imageUrl: _editedProduct.imageUrl);
                  },
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
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter an image URL';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'please enter a valid URL.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        //doing .done is what you use to submit the ENTIRE form, so make sure its last. Also need to use onFieldSubmitted
                        textInputAction: TextInputAction.done,
                        //need to use an anon function because onFieldSubmitted expects a String, so I can't just point to a  void function.
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: value);
                        },
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
