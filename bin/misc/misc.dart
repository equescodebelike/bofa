import 'package:postgres/postgres.dart';

const jsonHeaders = {
  'content-type': 'application/json',
};

final endPoint = Endpoint(
  host: 'localhost',
  port: 8090,
  database: 'mypod',
  username: 'postgres',
  password: '2qBi9o2Bhvv7U3YgeN1dItQpxL1izTBR',
);

const settings = ConnectionSettings(sslMode: SslMode.disable);
