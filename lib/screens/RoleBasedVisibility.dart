import 'package:flutter/material.dart';
import 'package:flutter_proje/models/user.dart';

class RoleBasedVisibility extends StatelessWidget {
  final User user;
  final bool Function(User user) isVisible;
  final Widget child;

  const RoleBasedVisibility({
    required this.user,
    required this.isVisible,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isVisible(user) ? child : SizedBox.shrink();
  }
}
