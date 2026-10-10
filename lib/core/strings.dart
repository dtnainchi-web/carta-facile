import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// The four app languages. Arabic is right-to-left.
const supportedLanguages = ['ar', 'fr', 'it', 'en'];

const languageNames = {
  'ar': 'العربية',
  'fr': 'Français',
  'it': 'Italiano',
  'en': 'English',
};

/// UI text in the four languages. Content (guides, lessons) lives in
/// assets/content/*.json with the same four language keys.
const Map<String, Map<String, String>> _strings = {
  'welcome': {
    'ar': 'مرحبًا بك',
    'fr': 'Bienvenue',
    'it': 'Benvenuto',
    'en': 'Welcome',
  },
  'tab_home': {'ar': 'الرئيسية', 'fr': 'Accueil', 'it': 'Home', 'en': 'Home'},
  'tab_guide': {'ar': 'الدليل', 'fr': 'Guide', 'it': 'Guida', 'en': 'Guide'},
  'tab_scan': {'ar': 'المسح', 'fr': 'Scanner', 'it': 'Scansione', 'en': 'Scan'},
  'tab_lessons': {'ar': 'الدروس', 'fr': 'Leçons', 'it': 'Lezioni', 'en': 'Lessons'},
  'tab_tracker': {
    'ar': 'المواعيد',
    'fr': 'Rendez-vous',
    'it': 'Scadenze',
    'en': 'Dates',
  },
  'your_permit': {
    'ar': 'تصريح إقامتك',
    'fr': 'Votre titre de séjour',
    'it': 'Il tuo permesso',
    'en': 'Your residence permit',
  },
  'days_left': {
    'ar': 'يومًا متبقيًا',
    'fr': 'jours restants',
    'it': 'giorni rimasti',
    'en': 'days left',
  },
  'renew_soon': {
    'ar': 'جدِّد قريبًا',
    'fr': 'À renouveler',
    'it': 'Da rinnovare',
    'en': 'Renew soon',
  },
  'expired': {
    'ar': 'منتهي الصلاحية',
    'fr': 'Expiré',
    'it': 'Scaduto',
    'en': 'Expired',
  },
  'expires_on': {
    'ar': 'ينتهي في',
    'fr': 'Expire le',
    'it': 'Scade il',
    'en': 'Expires on',
  },
  'add_permit_date': {
    'ar': 'أضف تاريخ انتهاء تصريح إقامتك لنذكّرك قبل الموعد',
    'fr': 'Ajoutez la date d\'expiration de votre titre de séjour pour recevoir un rappel',
    'it': 'Aggiungi la scadenza del tuo permesso per ricevere un promemoria',
    'en': 'Add your permit expiry date to get a reminder in time',
  },
  'set_date': {
    'ar': 'حدِّد التاريخ',
    'fr': 'Choisir la date',
    'it': 'Imposta la data',
    'en': 'Set date',
  },
  'scan_cta': {
    'ar': 'صوِّر رسالة وافهمها',
    'fr': 'Photographiez une lettre et comprenez-la',
    'it': 'Fotografa una lettera e capiscila',
    'en': 'Snap a letter and understand it',
  },
  'documents': {
    'ar': 'الوثائق',
    'fr': 'Documents',
    'it': 'Documenti',
    'en': 'Documents',
  },
  'steps': {'ar': 'خطوات', 'fr': 'étapes', 'it': 'passaggi', 'en': 'steps'},
  'in_italian': {
    'ar': 'بالإيطالية',
    'fr': 'En italien',
    'it': 'In italiano',
    'en': 'In Italian',
  },
  'tip': {'ar': 'نصيحة', 'fr': 'Conseil', 'it': 'Consiglio', 'en': 'Tip'},
  'disclaimer': {
    'ar': 'معلومات عامة للمساعدة، وليست استشارة قانونية رسمية. تحقّق دائمًا من الجهة المختصة.',
    'fr': 'Informations générales, pas un conseil juridique officiel. Vérifiez toujours auprès de l\'administration.',
    'it': 'Informazioni generali, non consulenza legale ufficiale. Verifica sempre con l\'ufficio competente.',
    'en': 'General information, not official legal advice. Always check with the relevant office.',
  },
  'scan_title': {
    'ar': 'شرح رسالة',
    'fr': 'Expliquer une lettre',
    'it': 'Spiega una lettera',
    'en': 'Explain a letter',
  },
  'scan_intro': {
    'ar': 'صوِّر رسالة أو وثيقة بالإيطالية، وسنشرحها لك بلغتك ونقول لك ما عليك فعله.',
    'fr': 'Photographiez une lettre en italien : nous l\'expliquons dans votre langue et vous disons quoi faire.',
    'it': 'Fotografa una lettera: te la spieghiamo in parole semplici e ti diciamo cosa fare.',
    'en': 'Photograph an Italian letter and we\'ll explain it in your language and tell you what to do.',
  },
  'take_photo': {
    'ar': 'التقط صورة',
    'fr': 'Prendre une photo',
    'it': 'Scatta una foto',
    'en': 'Take a photo',
  },
  'from_gallery': {
    'ar': 'من المعرض',
    'fr': 'Depuis la galerie',
    'it': 'Dalla galleria',
    'en': 'From gallery',
  },
  'analyzing': {
    'ar': 'جارٍ تحليل الرسالة…',
    'fr': 'Analyse de la lettre…',
    'it': 'Sto analizzando la lettera…',
    'en': 'Reading the letter…',
  },
  'from_office': {
    'ar': 'من الجهة',
    'fr': 'De la part de',
    'it': 'Mittente',
    'en': 'From',
  },
  'what_to_do': {
    'ar': 'ما الذي عليك فعله',
    'fr': 'Ce que vous devez faire',
    'it': 'Cosa devi fare',
    'en': 'What you need to do',
  },
  'deadline': {
    'ar': 'آخر أجل',
    'fr': 'Date limite',
    'it': 'Scadenza',
    'en': 'Deadline',
  },
  'scans_left': {
    'ar': 'مسحات مجانية متبقية هذا الشهر:',
    'fr': 'Scans gratuits restants ce mois-ci :',
    'it': 'Scansioni gratuite rimaste questo mese:',
    'en': 'Free scans left this month:',
  },
  'scan_limit_reached': {
    'ar': 'استعملت كل المسحات المجانية لهذا الشهر. اشترك في النسخة المميزة لمسح بلا حدود.',
    'fr': 'Vous avez utilisé tous vos scans gratuits ce mois-ci. Passez à Premium pour des scans illimités.',
    'it': 'Hai usato tutte le scansioni gratuite del mese. Passa a Premium per scansioni illimitate.',
    'en': 'You\'ve used all free scans this month. Go Premium for unlimited scans.',
  },
  'error_generic': {
    'ar': 'حدث خطأ. تحقّق من الاتصال وحاول مرة أخرى.',
    'fr': 'Une erreur s\'est produite. Vérifiez la connexion et réessayez.',
    'it': 'Si è verificato un errore. Controlla la connessione e riprova.',
    'en': 'Something went wrong. Check your connection and try again.',
  },
  'privacy_note': {
    'ar': 'لا نحتفظ بصورة رسالتك بعد التحليل.',
    'fr': 'Nous ne conservons pas la photo après l\'analyse.',
    'it': 'Non conserviamo la foto dopo l\'analisi.',
    'en': 'We don\'t keep your photo after the analysis.',
  },
  'scan_again': {
    'ar': 'مسح رسالة أخرى',
    'fr': 'Scanner une autre lettre',
    'it': 'Scansiona un\'altra lettera',
    'en': 'Scan another letter',
  },
  'lessons_title': {
    'ar': 'تعلّم الإيطالية',
    'fr': 'Apprendre l\'italien',
    'it': 'Impara l\'italiano',
    'en': 'Learn Italian',
  },
  'lessons_sub': {
    'ar': 'جمل تحتاجها في حياتك اليومية',
    'fr': 'Les phrases utiles au quotidien',
    'it': 'Le frasi che servono ogni giorno',
    'en': 'Phrases you need in daily life',
  },
  'your_progress': {
    'ar': 'تقدّمك',
    'fr': 'Votre progression',
    'it': 'I tuoi progressi',
    'en': 'Your progress',
  },
  'of': {'ar': 'من', 'fr': 'sur', 'it': 'su', 'en': 'of'},
  'lessons_word': {'ar': 'دروس', 'fr': 'leçons', 'it': 'lezioni', 'en': 'lessons'},
  'continue': {'ar': 'تابع', 'fr': 'Continuer', 'it': 'Continua', 'en': 'Continue'},
  'minutes': {'ar': 'دقائق', 'fr': 'min', 'it': 'min', 'en': 'min'},
  'what_to_bring': {
    'ar': 'ما يجب أن تحضره',
    'fr': 'À apporter',
    'it': 'Cosa portare',
    'en': 'What to bring',
  },
  'tools': {'ar': 'أدوات', 'fr': 'Outils', 'it': 'Strumenti', 'en': 'Tools'},
  'tool_status': {
    'ar': 'حالة تصريح الإقامة',
    'fr': 'État du titre de séjour',
    'it': 'Stato del permesso',
    'en': 'Permit status',
  },
  'tool_offices': {
    'ar': 'مكاتب قريبة',
    'fr': 'Bureaux proches',
    'it': 'Uffici vicini',
    'en': 'Offices nearby',
  },
  'tool_letter': {
    'ar': 'اكتب رسالة',
    'fr': 'Écrire une lettre',
    'it': 'Scrivi una lettera',
    'en': 'Write a letter',
  },
  'tool_wallet': {
    'ar': 'وثائقي',
    'fr': 'Mes documents',
    'it': 'I miei documenti',
    'en': 'My documents',
  },
  'status_intro': {
    'ar': 'يمكنك معرفة إن كان تصريح إقامتك جاهزًا على موقع الشرطة الإيطالية الرسمي.',
    'fr': 'Vous pouvez savoir si votre titre de séjour est prêt sur le site officiel de la police italienne.',
    'it': 'Puoi sapere se il tuo permesso è pronto sul sito ufficiale della Polizia di Stato.',
    'en': 'You can check if your permit is ready on the official Italian police website.',
  },
  'status_where_code': {
    'ar': 'أين أجد الرقم؟',
    'fr': 'Où trouver le numéro ?',
    'it': 'Dove trovo il numero?',
    'en': 'Where do I find the number?',
  },
  'status_code_help': {
    'ar': 'على الإيصال الذي أعطاك إياه مكتب البريد عند إرسال الملف: رقم الملف (10 خانات) أو رقم Assicurata (12 خانة).',
    'fr': 'Sur le reçu de la poste remis lors de l\'envoi du dossier : numéro de dossier (10 caractères) ou numéro d\'assurée (12 caractères).',
    'it': 'Sulla ricevuta delle Poste data quando hai spedito il kit: numero di pratica (10 caratteri) o numero di assicurata (12 caratteri).',
    'en': 'On the post office receipt you got when you sent the kit: file number (10 characters) or "assicurata" number (12 characters).',
  },
  'open_official_site': {
    'ar': 'افتح الموقع الرسمي',
    'fr': 'Ouvrir le site officiel',
    'it': 'Apri il sito ufficiale',
    'en': 'Open the official website',
  },
  'offices_intro': {
    'ar': 'اختر نوع المكتب، وسنفتح لك الخريطة بأقرب المكاتب إليك.',
    'fr': 'Choisissez le type de bureau : la carte s\'ouvre avec les plus proches.',
    'it': 'Scegli il tipo di ufficio: apriamo la mappa con quelli più vicini.',
    'en': 'Choose the type of office and we\'ll open the map with the nearest ones.',
  },
  'office_patronato': {
    'ar': 'Patronato و CAF (مساعدة مجانية)',
    'fr': 'Patronato et CAF (aide gratuite)',
    'it': 'Patronato e CAF (aiuto gratuito)',
    'en': 'Patronato & CAF (free help)',
  },
  'office_questura': {
    'ar': 'Questura (مكتب الأجانب)',
    'fr': 'Questura (bureau des étrangers)',
    'it': 'Questura (ufficio immigrazione)',
    'en': 'Questura (immigration office)',
  },
  'office_post': {
    'ar': 'مكتب بريد فيه Sportello Amico',
    'fr': 'Poste avec Sportello Amico',
    'it': 'Ufficio postale con Sportello Amico',
    'en': 'Post office with Sportello Amico',
  },
  'office_asl': {
    'ar': 'ASL (الصحة)',
    'fr': 'ASL (santé)',
    'it': 'ASL (sanità)',
    'en': 'ASL (health)',
  },
  'office_comune': {
    'ar': 'البلدية (Anagrafe)',
    'fr': 'Mairie (Anagrafe)',
    'it': 'Comune (Anagrafe)',
    'en': 'Town hall (Anagrafe)',
  },
  'office_entrate': {
    'ar': 'Agenzia delle Entrate (الضرائب)',
    'fr': 'Agenzia delle Entrate (impôts)',
    'it': 'Agenzia delle Entrate',
    'en': 'Agenzia delle Entrate (tax office)',
  },
  'wallet_intro': {
    'ar': 'أضف تاريخ انتهاء كل وثيقة، وسنذكّرك قبل أن تنتهي.',
    'fr': 'Ajoutez la date d\'expiration de chaque document : nous vous le rappellerons.',
    'it': 'Aggiungi la scadenza di ogni documento: ti avviseremo in tempo.',
    'en': 'Add each document\'s expiry date and we\'ll remind you before it expires.',
  },
  'doc_passport': {'ar': 'جواز السفر', 'fr': 'Passeport', 'it': 'Passaporto', 'en': 'Passport'},
  'doc_id': {
    'ar': 'بطاقة الهوية الإيطالية',
    'fr': 'Carte d\'identité italienne',
    'it': 'Carta d\'identità',
    'en': 'Italian ID card',
  },
  'doc_licence': {
    'ar': 'رخصة السياقة',
    'fr': 'Permis de conduire',
    'it': 'Patente di guida',
    'en': 'Driving licence',
  },
  'doc_health': {
    'ar': 'البطاقة الصحية',
    'fr': 'Carte de santé',
    'it': 'Tessera sanitaria',
    'en': 'Health card',
  },
  'doc_isee': {'ar': 'شهادة ISEE', 'fr': 'Attestation ISEE', 'it': 'ISEE', 'en': 'ISEE certificate'},
  'not_set': {
    'ar': 'لم تُحدَّد بعد',
    'fr': 'Pas encore définie',
    'it': 'Non impostata',
    'en': 'Not set yet',
  },
  'letter_intro': {
    'ar': 'اكتب بلغتك ما تريد قوله، وسنكتب لك رسالة واضحة ومهذّبة بالإيطالية.',
    'fr': 'Écrivez dans votre langue ce que vous voulez dire : nous rédigeons une lettre claire et polie en italien.',
    'it': 'Scrivi cosa vuoi dire e preparo una lettera chiara e cortese in italiano.',
    'en': 'Write what you want to say in your language and we\'ll write a clear, polite letter in Italian.',
  },
  'letter_to': {'ar': 'إلى من؟', 'fr': 'À qui ?', 'it': 'A chi?', 'en': 'To whom?'},
  'to_landlord': {
    'ar': 'صاحب السكن',
    'fr': 'Propriétaire',
    'it': 'Proprietario di casa',
    'en': 'Landlord',
  },
  'to_employer': {'ar': 'المشغّل', 'fr': 'Employeur', 'it': 'Datore di lavoro', 'en': 'Employer'},
  'to_office': {
    'ar': 'إدارة أو مكتب',
    'fr': 'Administration',
    'it': 'Ufficio pubblico',
    'en': 'Public office',
  },
  'to_school': {'ar': 'المدرسة', 'fr': 'École', 'it': 'Scuola', 'en': 'School'},
  'to_other': {'ar': 'آخر', 'fr': 'Autre', 'it': 'Altro', 'en': 'Other'},
  'letter_hint': {
    'ar': 'مثال: أريد أن أطلب من صاحب السكن إصلاح سخان الماء لأنه معطّل منذ أسبوع.',
    'fr': 'Ex. : je veux demander au propriétaire de réparer le chauffe-eau en panne depuis une semaine.',
    'it': 'Es.: voglio chiedere al proprietario di riparare lo scaldabagno rotto da una settimana.',
    'en': 'E.g. I want to ask my landlord to fix the water heater, broken for a week.',
  },
  'write_it': {
    'ar': 'اكتب الرسالة بالإيطالية',
    'fr': 'Rédiger en italien',
    'it': 'Scrivi la lettera',
    'en': 'Write it in Italian',
  },
  'writing': {
    'ar': 'جارٍ كتابة الرسالة…',
    'fr': 'Rédaction en cours…',
    'it': 'Sto scrivendo…',
    'en': 'Writing…',
  },
  'letter_italian': {
    'ar': 'الرسالة بالإيطالية',
    'fr': 'La lettre en italien',
    'it': 'La lettera',
    'en': 'The letter in Italian',
  },
  'letter_meaning': {
    'ar': 'معناها بلغتك',
    'fr': 'Ce qu\'elle dit',
    'it': 'Cosa dice',
    'en': 'What it says',
  },
  'copy': {'ar': 'نسخ', 'fr': 'Copier', 'it': 'Copia', 'en': 'Copy'},
  'copied': {'ar': 'تم النسخ', 'fr': 'Copié', 'it': 'Copiato', 'en': 'Copied'},
  'translation_in': {
    'ar': 'الترجمة إلى:',
    'fr': 'Traduction en :',
    'it': 'Traduzione in:',
    'en': 'Translation in:',
  },
  'phrases': {'ar': 'الجمل', 'fr': 'Phrases', 'it': 'Frasi', 'en': 'Phrases'},
  'quiz': {'ar': 'تمرين', 'fr': 'Exercice', 'it': 'Esercizio', 'en': 'Quiz'},
  'correct': {
    'ar': 'إجابة صحيحة!',
    'fr': 'Bonne réponse !',
    'it': 'Risposta giusta!',
    'en': 'Correct!',
  },
  'wrong': {
    'ar': 'حاول مرة أخرى',
    'fr': 'Essayez encore',
    'it': 'Riprova',
    'en': 'Try again',
  },
  'finish_lesson': {
    'ar': 'أنهيت الدرس',
    'fr': 'Terminer la leçon',
    'it': 'Lezione completata',
    'en': 'Finish lesson',
  },
  'my_dates': {
    'ar': 'مواعيدي',
    'fr': 'Mes rendez-vous',
    'it': 'Le mie scadenze',
    'en': 'My dates',
  },
  'upcoming': {'ar': 'القادمة', 'fr': 'À venir', 'it': 'In arrivo', 'en': 'Upcoming'},
  'no_dates': {
    'ar': 'لا توجد مواعيد بعد. أضف موعدك الأول.',
    'fr': 'Aucun rendez-vous pour l\'instant. Ajoutez le premier.',
    'it': 'Nessuna scadenza per ora. Aggiungi la prima.',
    'en': 'No dates yet. Add your first one.',
  },
  'add_date': {
    'ar': 'إضافة موعد',
    'fr': 'Ajouter un rendez-vous',
    'it': 'Aggiungi scadenza',
    'en': 'Add a date',
  },
  'title_label': {'ar': 'العنوان', 'fr': 'Titre', 'it': 'Titolo', 'en': 'Title'},
  'place_label': {
    'ar': 'المكان (اختياري)',
    'fr': 'Lieu (facultatif)',
    'it': 'Luogo (facoltativo)',
    'en': 'Place (optional)',
  },
  'save': {'ar': 'حفظ', 'fr': 'Enregistrer', 'it': 'Salva', 'en': 'Save'},
  'cancel': {'ar': 'إلغاء', 'fr': 'Annuler', 'it': 'Annulla', 'en': 'Cancel'},
  'delete': {'ar': 'حذف', 'fr': 'Supprimer', 'it': 'Elimina', 'en': 'Delete'},
  'in_days': {'ar': 'بعد', 'fr': 'Dans', 'it': 'Tra', 'en': 'In'},
  'days': {'ar': 'يومًا', 'fr': 'jours', 'it': 'giorni', 'en': 'days'},
  'today': {'ar': 'اليوم', 'fr': 'Aujourd\'hui', 'it': 'Oggi', 'en': 'Today'},
  'reminders': {
    'ar': 'التذكيرات',
    'fr': 'Rappels',
    'it': 'Promemoria',
    'en': 'Reminders',
  },
  'before_60': {
    'ar': 'قبل 60 يومًا',
    'fr': '60 jours avant',
    'it': '60 giorni prima',
    'en': '60 days before',
  },
  'before_30': {
    'ar': 'قبل 30 يومًا',
    'fr': '30 jours avant',
    'it': '30 giorni prima',
    'en': '30 days before',
  },
  'before_1': {
    'ar': 'قبل يوم واحد',
    'fr': 'La veille',
    'it': 'Il giorno prima',
    'en': '1 day before',
  },
  'permit_expiry': {
    'ar': 'انتهاء تصريح الإقامة',
    'fr': 'Expiration du titre de séjour',
    'it': 'Scadenza del permesso',
    'en': 'Permit expiry',
  },
  'reminder_body': {
    'ar': 'لديك موعد قادم في Carta Facile',
    'fr': 'Vous avez une échéance dans Carta Facile',
    'it': 'Hai una scadenza in arrivo su Carta Facile',
    'en': 'You have an upcoming date in Carta Facile',
  },
  'language': {'ar': 'اللغة', 'fr': 'Langue', 'it': 'Lingua', 'en': 'Language'},
};

/// Returns the UI string for [key] in the current app language.
String tr(String key) {
  final lang = appState.language;
  final entry = _strings[key];
  if (entry == null) return key;
  return entry[lang] ?? entry['en'] ?? key;
}

/// Picks the right language from a content map like {"ar": ..., "fr": ...}.
String pick(Map<String, dynamic>? localized) {
  if (localized == null) return '';
  final lang = appState.language;
  return (localized[lang] ?? localized['en'] ?? localized['it'] ?? '').toString();
}

/// Second line under a title: normally the Italian name; when the app is
/// in Italian, the title in the user's translation language instead
/// (so the two lines never repeat the same Italian text).
String secondLine(Map<String, dynamic> localizedTitle, String italianName) {
  if (appState.language != 'it') return italianName;
  final lang = appState.helpLanguage;
  return (localizedTitle[lang] ?? localizedTitle['en'] ?? italianName).toString();
}

TextDirection get secondLineDirection =>
    appState.language == 'it' && appState.helpLanguage == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

TextDirection get appDirection =>
    appState.language == 'ar' ? TextDirection.rtl : TextDirection.ltr;
