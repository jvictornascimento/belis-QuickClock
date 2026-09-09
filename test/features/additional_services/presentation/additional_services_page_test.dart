import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/data/repositories/additional_service_repository.dart';
import 'package:ponto_eletronico/features/additional_services/presentation/additional_services_page.dart';
import 'package:ponto_eletronico/models/additional_service.dart';

void main() {
  testWidgets('shows saved services for the current month', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdditionalServicesPage(
          additionalServiceRepository: FakeAdditionalServiceRepository(
            services: [_service('2026-08-25', 'Instalacao extra', 5000)],
          ),
          nowProvider: () => DateTime(2026, 8, 25),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Servicos adicionais'), findsOneWidget);
    expect(find.widgetWithText(TextField, '2026-08-25'), findsOneWidget);
    expect(find.text('Instalacao extra'), findsOneWidget);
    expect(find.text('R\$ 50,00'), findsOneWidget);
    expect(find.text('Total adicional: R\$ 50,00'), findsOneWidget);
  });

  testWidgets('saves a new service', (tester) async {
    final repository = FakeAdditionalServiceRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: AdditionalServicesPage(
          additionalServiceRepository: repository,
          nowProvider: () => DateTime(2026, 8, 25),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'Manutencao');
    await tester.enterText(find.byType(TextField).at(2), '75,00');
    await tester.tap(find.text('Adicionar servico'));
    await tester.pumpAndSettle();

    expect(repository.savedService?.date, '2026-08-25');
    expect(repository.savedService?.description, 'Manutencao');
    expect(repository.savedService?.valueCents, 7500);
    expect(find.text('Servico salvo.'), findsOneWidget);
  });
}

class FakeAdditionalServiceRepository extends AdditionalServiceRepository {
  FakeAdditionalServiceRepository({this.services = const []})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  List<AdditionalService> services;
  AdditionalService? savedService;

  @override
  Future<List<AdditionalService>> findByMonth(String month) async {
    return services.where((service) => service.date.startsWith(month)).toList();
  }

  @override
  Future<AdditionalService> save(AdditionalService service) async {
    savedService = service.copyWith(id: 1);
    services = [...services, savedService!];

    return savedService!;
  }
}

AdditionalService _service(String date, String description, int valueCents) {
  final now = DateTime(2026, 8, 25);

  return AdditionalService(
    id: 1,
    date: date,
    description: description,
    valueCents: valueCents,
    createdAt: now,
    updatedAt: now,
  );
}
