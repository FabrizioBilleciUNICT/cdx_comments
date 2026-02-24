// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class CdxCommentsLocalizationsIt extends CdxCommentsLocalizations {
  CdxCommentsLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get comments => 'Commenti';

  @override
  String get add_a_comment => 'Aggiungi un commento...';

  @override
  String get answer => 'Rispondi';

  @override
  String get answer_to => 'Rispondi a';

  @override
  String get delete => 'Elimina';

  @override
  String get delete_comment => 'Elimina commento';

  @override
  String get q_delete_comment =>
      'Sei sicuro di voler eliminare questo commento?';

  @override
  String get confirm => 'Conferma';

  @override
  String get cancel => 'Annulla';

  @override
  String get report => 'Segnala';

  @override
  String get q_report_comment => 'Perché stai segnalando questo commento?';

  @override
  String get q_report_user => 'Cosa vuoi fare?';

  @override
  String get report_user => 'Segnala utente';

  @override
  String get block_user => 'Blocca utente';

  @override
  String get next => 'Avanti';

  @override
  String get end => 'Invia';

  @override
  String get report_done => 'Segnalazione inviata con successo';

  @override
  String get blocked_until => 'Bloccato fino al';

  @override
  String view_replies(int count) {
    return 'Visualizza $count risposte';
  }

  @override
  String get load_more_replies => 'Carica altre risposte';

  @override
  String get comment_empty => 'Il commento non può essere vuoto';

  @override
  String comment_too_many_lines(int maxLines) {
    return 'Il commento non può superare $maxLines righe';
  }

  @override
  String comment_too_long(int maxLength) {
    return 'Il commento non può superare $maxLength caratteri';
  }

  @override
  String get comment_dangerous => 'Il commento contiene contenuti pericolosi';

  @override
  String get comment_bad_words => 'Il commento contiene parole inappropriate';
}
