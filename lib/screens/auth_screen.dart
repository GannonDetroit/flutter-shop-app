import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      //transform allows you to change how the container is presented, move it, scale it, rotate it, etc.
                      //pi comes from the dart.math package, .rotationZ is using the z-axis which is "through" the device, its the 3d axis of a cube coming towards or away from you.
                      //this isn't making things 3D exactly, it just adds a slight angle to properties.
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        //translate is a method that offsets the object or adds some offseting configuration to the object
                        // double dot notion .. is used to avoid an issue where if you did singl dot notion and put .translate at the end of the transform: it would return void because
                        //when you chain things only the last thing is returned, but if you use .. then you can void this void/null return issue since it's  a dart specific feature that returns
                        //not the last things return but the one previous to it, so the .rotationZ returns. But it still is affected by ..translate. since it doensn't return a new object, it just edits
                        //the object on which it was called. its just a shorthand method to avoid needing to use multiple lines of code to set up something, call a method on it and use/return the orginal object.
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Gannon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  //animationController,Animatio, and Size are provided by flutter;
  //the controller is to help start and revert the animation and Animation is to do the heavy lifting of the actual animation.
  AnimationController _controller;
  Animation<Size> _heightAnimation;

  @override
  void initState() {
    //vsync gives the animation a pointer to the object/widget its suppose to watch (only when its on the screen, it has optization built in too).
    //had to add SingleTickerProviderStateMixin, which allows the app to know when/if a widget is visible, which is why we use the 'this' keyword here.
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    //the tween class is a class that just knows how to animate between two values. since I only want to animate height differences i keep width the same and specify what the heights are.
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Curves
                .linear)); //curve how you change up the animation within the duration, you do linear, fastOutSlowIn, check the docs there are many options.
    super.initState();
  }

//kill the controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Ok'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      } else {
        // Sign user up
        //listen: false because if you're on the auth screen you're always unauthed and you're just sending a POST so you don't need to listen here.
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email'], _authData['password']);
      }
      //do a catch for specific httpException errors
    } on HttpException catch (err) {
      //doing it this way just as a demo, you can use switch statement instead, you can do a lot of this differently.
      var errorMessage = 'Auth HTTP Error';
      if (err.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (err.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'that is not a valid email';
      } else if (err.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'password is too weak';
      } else if (err.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'could not find a user with that email';
      } else if (err.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'invalid password, try agian.';
      }
      _showErrorDialog(errorMessage);
    }
    //do a catch for any other random errors like losing internet connection.
    catch (err) {
      const errorMessage = 'could not authenticate, please try again later';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      //starts the animation.
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      //reverses it.
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      //using animated builder has flutter handle things. it will execute something for me and then rebuilds the UI after that something is done.
      //the childd arg is for putting in the child widgets of my animated widget. this prevents the child from being re-rendered and improves performance.
      //so i'm animating the container, and its child is Form. I'm telling the AnimatedBuilder to animate Container but don't rerender Form since its child
      //I spelt it childd so I can see the differences between the two widgets better.
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, childd) => Container(
            // height: _authMode == AuthMode.Signup ? 320 : 260,
            height: _heightAnimation.value.height,
            constraints:
                BoxConstraints(minHeight: _heightAnimation.value.height),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: childd),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  //don't feel like refactoring these right now.
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
