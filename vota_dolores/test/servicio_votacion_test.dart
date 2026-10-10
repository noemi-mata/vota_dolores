import 'package:flutter_test/flutter_test.dart';
import 'package:vota_dolores/logica/resultado_voto.dart';
import 'package:vota_dolores/logica/servicio_votacion.dart';
import 'package:vota_dolores/modelos/opcion_votacion.dart';
import 'package:vota_dolores/modelos/votacion.dart';

Votacion crearVotacionDePrueba({DateTime? fechaCierre}) {
  return Votacion(
    pregunta: 'Pregunta de prueba',
    opciones: [
      OpcionVotacion(id: 'op1', texto: 'Opcion 1'),
      OpcionVotacion(id: 'op2', texto: 'Opcion 2'),
    ],
    fechaCierre: fechaCierre ?? DateTime.now().add(const Duration(days: 7)),
  );
}

void main() {
  test('registrar un voto valido incrementa el contador de esa opcion', () {
    final votacion = crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);
    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
    
    expect(resultado, ResultadoVoto.exitoso);
    expect(votacion.opciones[0].votos, 1);
  });

  test('votar por una opcion que no existe regresa opcionInvalida', () {
    final votacion = crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);
    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'no-existe');
    
    expect(resultado, ResultadoVoto.opcionInvalida);
  });

  test('un mismo usuario no puede votar dos veces', () {
    final votacion = crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);
    servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
    final segundoIntento = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op2');
    
    expect(segundoIntento, ResultadoVoto.usuarioYaVoto);
    expect(votacion.opciones[1].votos, 0); // op2 no debio incrementarse
  });

  test('no se puede votar si la votacion ya cerro', () {
    final votacionCerrada = crearVotacionDePrueba(
      fechaCierre: DateTime(2000, 1, 1), // una fecha muy en el pasado
    );
    final servicio = ServicioVotacion(votacionCerrada);
    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
    
    expect(resultado, ResultadoVoto.votacionCerrada);
    expect(votacionCerrada.opciones[0].votos, 0);
  });

  test('si la votacion sigue abierta, el voto se registra normalmente', () {
    final votacionAbierta = crearVotacionDePrueba(
      fechaCierre: DateTime.now().add(const Duration(days: 1)),
    );
    final servicio = ServicioVotacion(votacionAbierta);
    final resultado = servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
    
    expect(resultado, ResultadoVoto.exitoso);
  });
}