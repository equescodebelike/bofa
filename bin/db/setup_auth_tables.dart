import 'dart:io';
import 'package:postgres/postgres.dart';
import '../misc/misc.dart';

Future<void> main() async {
  print('Setting up authentication tables...');
  
  // Connect to the database
  var connection = await Connection.open(
    endPoint,
    settings: settings,
  );
  
  try {
    // Read the SQL file
    final sqlFile = File('bin/db/auth_tables.sql');
    final sqlScript = await sqlFile.readAsString();
    
    // Split the script into individual statements
    final statements = sqlScript.split(';')
        .where((statement) => statement.trim().isNotEmpty)
        .map((statement) => statement.trim() + ';')
        .toList();
    
    // Execute each statement
    for (var statement in statements) {
      print('Executing: ${statement.substring(0, statement.length > 50 ? 50 : statement.length)}...');
      await connection.execute(statement);
    }
    
    print('Authentication tables setup completed successfully!');
  } catch (e) {
    print('Error setting up authentication tables: $e');
  } finally {
    await connection.close();
  }
}
