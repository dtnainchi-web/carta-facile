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

TextDirection get appDirection =>
    appState.language == 'ar' ? TextDirection.rtl : TextDirection.ltr;
