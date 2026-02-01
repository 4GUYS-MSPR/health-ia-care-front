import 'package:get_it/get_it.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/members_remote_datasources.dart';
import '../data/repositories/members_repository_impl.dart';
import '../domain/repositories/members_repository.dart';
import '../domain/usecases/create_member_usecase.dart';
import '../domain/usecases/delete_member_usecase.dart';
import '../domain/usecases/get_all_members_usecase.dart';
import '../domain/usecases/get_member_usecase.dart';
import '../domain/usecases/update_member_usecase.dart';
import '../presentation/bloc/members_bloc.dart';

void registerMembersFeature(GetIt sl) {
  _registerDatasources(sl);
  _registerRepositories(sl);
  _registerUsecases(sl);
  _registerBlocsAndCubits(sl);
}

void _registerDatasources(GetIt sl) {
  sl.registerFactory<MembersRemoteDatasources>(
    () => MembersRemoteDatasourcesImpl(
      membersClient: sl(),
    ),
  );
}

void _registerRepositories(GetIt sl) {
  sl.registerFactory<MembersRepository>(
    () => MembersRepositoryImpl(
      remoteDatasources: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerUsecases(GetIt sl) {
  sl.registerFactory(
    () => GetAllMembersUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => GetMemberUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => CreateMemberUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => UpdateMemberUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => DeleteMemberUsecase(repository: sl()),
  );
}

void _registerBlocsAndCubits(GetIt sl) {
  sl.registerFactory(
    () => MembersBloc(
      getAllMembersUsecase: sl(),
      createMemberUsecase: sl(),
      updateMemberUsecase: sl(),
      deleteMemberUsecase: sl(),
    ),
  );
}
