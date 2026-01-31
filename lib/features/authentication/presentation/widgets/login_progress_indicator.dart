import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/login_process_cubit/login_process_cubit.dart';

class LoginProgressIndicator extends StatelessWidget {
  const LoginProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginProcessCubit, LoginProcessState>(
      builder: (context, state) {
        if (state is LoginProcessLoadingState) {
          return LinearProgressIndicator();
        }
        return Container();
      },
    );
  }
}
