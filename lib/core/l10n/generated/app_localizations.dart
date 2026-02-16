import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'XtractAid'**
  String get appTitle;

  /// No description provided for @navProjects.
  ///
  /// In de, this message translates to:
  /// **'Projekte'**
  String get navProjects;

  /// No description provided for @navModels.
  ///
  /// In de, this message translates to:
  /// **'Modelle'**
  String get navModels;

  /// No description provided for @navSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get navSettings;

  /// No description provided for @actionBack.
  ///
  /// In de, this message translates to:
  /// **'Zurueck'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get actionNext;

  /// No description provided for @actionCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In de, this message translates to:
  /// **'Schliessen'**
  String get actionClose;

  /// No description provided for @actionSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In de, this message translates to:
  /// **'Loeschen'**
  String get actionDelete;

  /// No description provided for @actionOpen.
  ///
  /// In de, this message translates to:
  /// **'Oeffnen'**
  String get actionOpen;

  /// No description provided for @actionCreate.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get actionCreate;

  /// No description provided for @actionChange.
  ///
  /// In de, this message translates to:
  /// **'Aendern'**
  String get actionChange;

  /// No description provided for @actionContinue.
  ///
  /// In de, this message translates to:
  /// **'Fortfahren'**
  String get actionContinue;

  /// No description provided for @actionDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get actionDone;

  /// No description provided for @actionStart.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionPause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionResume.
  ///
  /// In de, this message translates to:
  /// **'Fortsetzen'**
  String get actionResume;

  /// No description provided for @actionStop.
  ///
  /// In de, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @actionChooseFolder.
  ///
  /// In de, this message translates to:
  /// **'Ordner waehlen'**
  String get actionChooseFolder;

  /// No description provided for @actionChooseFile.
  ///
  /// In de, this message translates to:
  /// **'Datei waehlen'**
  String get actionChooseFile;

  /// No description provided for @actionLoad.
  ///
  /// In de, this message translates to:
  /// **'Laden'**
  String get actionLoad;

  /// No description provided for @actionSelect.
  ///
  /// In de, this message translates to:
  /// **'Waehlen'**
  String get actionSelect;

  /// No description provided for @actionUnlock.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get actionUnlock;

  /// No description provided for @actionReset.
  ///
  /// In de, this message translates to:
  /// **'Zuruecksetzen'**
  String get actionReset;

  /// No description provided for @actionTestConnection.
  ///
  /// In de, this message translates to:
  /// **'Verbindung testen'**
  String get actionTestConnection;

  /// No description provided for @labelLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get labelLanguage;

  /// No description provided for @labelGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get labelGerman;

  /// No description provided for @labelEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get labelEnglish;

  /// No description provided for @labelPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get labelPassword;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestaetigen'**
  String get labelConfirmPassword;

  /// No description provided for @labelCurrentPassword.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Passwort'**
  String get labelCurrentPassword;

  /// No description provided for @labelNewPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get labelNewPassword;

  /// No description provided for @labelConfirmNewPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort bestaetigen'**
  String get labelConfirmNewPassword;

  /// No description provided for @labelMasterPassword.
  ///
  /// In de, this message translates to:
  /// **'Master-Passwort'**
  String get labelMasterPassword;

  /// No description provided for @labelApiKey.
  ///
  /// In de, this message translates to:
  /// **'API-Key'**
  String get labelApiKey;

  /// No description provided for @labelProvider.
  ///
  /// In de, this message translates to:
  /// **'Provider'**
  String get labelProvider;

  /// No description provided for @labelModel.
  ///
  /// In de, this message translates to:
  /// **'Model'**
  String get labelModel;

  /// No description provided for @labelProjectName.
  ///
  /// In de, this message translates to:
  /// **'Projektname'**
  String get labelProjectName;

  /// No description provided for @labelStatus.
  ///
  /// In de, this message translates to:
  /// **'Status:'**
  String get labelStatus;

  /// No description provided for @labelUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get labelUnknown;

  /// No description provided for @labelLocal.
  ///
  /// In de, this message translates to:
  /// **'lokal'**
  String get labelLocal;

  /// No description provided for @labelCloud.
  ///
  /// In de, this message translates to:
  /// **'cloud'**
  String get labelCloud;

  /// No description provided for @setupTitle.
  ///
  /// In de, this message translates to:
  /// **'Ersteinrichtung'**
  String get setupTitle;

  /// No description provided for @setupStepWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen'**
  String get setupStepWelcome;

  /// No description provided for @setupStepPassword.
  ///
  /// In de, this message translates to:
  /// **'Master-Passwort'**
  String get setupStepPassword;

  /// No description provided for @setupStepProvider.
  ///
  /// In de, this message translates to:
  /// **'Provider waehlen'**
  String get setupStepProvider;

  /// No description provided for @setupStepApiKey.
  ///
  /// In de, this message translates to:
  /// **'API-Key und Test'**
  String get setupStepApiKey;

  /// No description provided for @setupStepBasicSettings.
  ///
  /// In de, this message translates to:
  /// **'Grundeinstellungen'**
  String get setupStepBasicSettings;

  /// No description provided for @setupStepFinish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get setupStepFinish;

  /// No description provided for @setupStartApp.
  ///
  /// In de, this message translates to:
  /// **'XtractAid starten'**
  String get setupStartApp;

  /// No description provided for @setupDescription.
  ///
  /// In de, this message translates to:
  /// **'XtractAid analysiert Textdaten aus Dateien in Batches mit LLM-Modellen und erstellt strukturierte Ergebnisse.'**
  String get setupDescription;

  /// No description provided for @setupGermanLabel.
  ///
  /// In de, this message translates to:
  /// **'Deutsch (DE)'**
  String get setupGermanLabel;

  /// No description provided for @setupEnglishLabel.
  ///
  /// In de, this message translates to:
  /// **'English (EN)'**
  String get setupEnglishLabel;

  /// No description provided for @setupProviderHint.
  ///
  /// In de, this message translates to:
  /// **'Cloud-Provider benoetigen einen API-Key. Lokale Provider (Ollama, LM Studio) laufen auf Ihrem Rechner.'**
  String get setupProviderHint;

  /// No description provided for @setupLocalApiKeyHint.
  ///
  /// In de, this message translates to:
  /// **'Lokaler Provider: API-Key wird nicht benoetigt. Bitte nur die Verbindung testen.'**
  String get setupLocalApiKeyHint;

  /// No description provided for @setupConnectionSuccess.
  ///
  /// In de, this message translates to:
  /// **'Verbindung erfolgreich.'**
  String get setupConnectionSuccess;

  /// No description provided for @setupConnectionFailed.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen.'**
  String get setupConnectionFailed;

  /// No description provided for @setupStrictLocalMode.
  ///
  /// In de, this message translates to:
  /// **'Strict Local Mode'**
  String get setupStrictLocalMode;

  /// No description provided for @setupStrictLocalModeDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur lokale Provider erlauben (Ollama, LM Studio).'**
  String get setupStrictLocalModeDesc;

  /// No description provided for @setupSettingsChangeLater.
  ///
  /// In de, this message translates to:
  /// **'Diese Einstellungen koennen spaeter in den Einstellungen geaendert werden.'**
  String get setupSettingsChangeLater;

  /// No description provided for @setupSummaryTitle.
  ///
  /// In de, this message translates to:
  /// **'Setup-Zusammenfassung'**
  String get setupSummaryTitle;

  /// No description provided for @setupSummaryConnection.
  ///
  /// In de, this message translates to:
  /// **'Verbindung'**
  String get setupSummaryConnection;

  /// No description provided for @setupSummaryPasswordSet.
  ///
  /// In de, this message translates to:
  /// **'Gesetzt'**
  String get setupSummaryPasswordSet;

  /// No description provided for @setupSummaryPasswordNotSet.
  ///
  /// In de, this message translates to:
  /// **'Nicht gesetzt'**
  String get setupSummaryPasswordNotSet;

  /// No description provided for @setupSummaryConnectionOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get setupSummaryConnectionOk;

  /// No description provided for @setupSummaryConnectionFail.
  ///
  /// In de, this message translates to:
  /// **'Nicht getestet/fehlgeschlagen'**
  String get setupSummaryConnectionFail;

  /// No description provided for @setupNoProviderData.
  ///
  /// In de, this message translates to:
  /// **'Keine Providerdaten gefunden.'**
  String get setupNoProviderData;

  /// No description provided for @setupProviderLoadError.
  ///
  /// In de, this message translates to:
  /// **'Provider konnten nicht geladen werden.'**
  String get setupProviderLoadError;

  /// No description provided for @setupSelectProvider.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Provider auswaehlen.'**
  String get setupSelectProvider;

  /// No description provided for @setupLanguageSaveError.
  ///
  /// In de, this message translates to:
  /// **'Sprache konnte nicht gespeichert werden.'**
  String get setupLanguageSaveError;

  /// No description provided for @setupMinPasswordLength.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen erforderlich.'**
  String get setupMinPasswordLength;

  /// No description provided for @setupPasswordMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwoerter stimmen nicht ueberein.'**
  String get setupPasswordMismatch;

  /// No description provided for @setupPasswordSaveError.
  ///
  /// In de, this message translates to:
  /// **'Passwort konnte nicht gespeichert werden.'**
  String get setupPasswordSaveError;

  /// No description provided for @setupNoProviderSelected.
  ///
  /// In de, this message translates to:
  /// **'Kein Provider ausgewaehlt.'**
  String get setupNoProviderSelected;

  /// No description provided for @setupEnterApiKey.
  ///
  /// In de, this message translates to:
  /// **'Bitte API-Key eingeben.'**
  String get setupEnterApiKey;

  /// No description provided for @setupTestConnectionFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte zuerst eine erfolgreiche Verbindung pruefen.'**
  String get setupTestConnectionFirst;

  /// No description provided for @setupProviderSaveError.
  ///
  /// In de, this message translates to:
  /// **'Provider konnte nicht gespeichert werden.'**
  String get setupProviderSaveError;

  /// No description provided for @setupSettingsSaveError.
  ///
  /// In de, this message translates to:
  /// **'Grundeinstellungen konnten nicht gespeichert werden.'**
  String get setupSettingsSaveError;

  /// No description provided for @setupCompleteError.
  ///
  /// In de, this message translates to:
  /// **'Setup konnte nicht abgeschlossen werden.'**
  String get setupCompleteError;

  /// No description provided for @passwordStrength.
  ///
  /// In de, this message translates to:
  /// **'Passwortstaerke'**
  String get passwordStrength;

  /// No description provided for @passwordWeak.
  ///
  /// In de, this message translates to:
  /// **'Schwach (unter 8 Zeichen)'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel (mindestens 8 Zeichen)'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In de, this message translates to:
  /// **'Stark (12+ Zeichen)'**
  String get passwordStrong;

  /// No description provided for @authEnterPassword.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben.'**
  String get authEnterPassword;

  /// No description provided for @authSetupIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Setup unvollstaendig. Bitte neu einrichten.'**
  String get authSetupIncomplete;

  /// No description provided for @authWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Falsches Passwort'**
  String get authWrongPassword;

  /// No description provided for @authUnlockFailed.
  ///
  /// In de, this message translates to:
  /// **'Entsperren fehlgeschlagen.'**
  String get authUnlockFailed;

  /// No description provided for @authForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authForgotPassword;

  /// No description provided for @authResetWarning.
  ///
  /// In de, this message translates to:
  /// **'Alle API-Keys werden geloescht. Fortfahren?'**
  String get authResetWarning;

  /// No description provided for @authResetFailed.
  ///
  /// In de, this message translates to:
  /// **'Reset fehlgeschlagen.'**
  String get authResetFailed;

  /// No description provided for @projectsTitle.
  ///
  /// In de, this message translates to:
  /// **'Projekte'**
  String get projectsTitle;

  /// No description provided for @projectsNew.
  ///
  /// In de, this message translates to:
  /// **'Neues Projekt'**
  String get projectsNew;

  /// No description provided for @projectsOpen.
  ///
  /// In de, this message translates to:
  /// **'Projekt oeffnen'**
  String get projectsOpen;

  /// No description provided for @projectsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Ihr erstes Projekt'**
  String get projectsEmpty;

  /// No description provided for @projectsCreateError.
  ///
  /// In de, this message translates to:
  /// **'Projekt konnte nicht erstellt werden.'**
  String get projectsCreateError;

  /// No description provided for @projectsInvalidProject.
  ///
  /// In de, this message translates to:
  /// **'Kein gueltiges XtractAid-Projekt'**
  String get projectsInvalidProject;

  /// No description provided for @projectsOpenError.
  ///
  /// In de, this message translates to:
  /// **'Projekt konnte nicht geoeffnet werden.'**
  String get projectsOpenError;

  /// No description provided for @projectsNotFound.
  ///
  /// In de, this message translates to:
  /// **'Projekt nicht gefunden.'**
  String get projectsNotFound;

  /// No description provided for @projectsLastOpened.
  ///
  /// In de, this message translates to:
  /// **'Letzte Oeffnung:'**
  String get projectsLastOpened;

  /// No description provided for @projectsNever.
  ///
  /// In de, this message translates to:
  /// **'Nie'**
  String get projectsNever;

  /// No description provided for @projectsDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Projekt \"{name}\" loeschen?\n\nPfad: {path}\n\nDu kannst nur den Listeneintrag entfernen oder das gesamte Projekt inklusive Ordner und aller Batch-Daten loeschen.'**
  String projectsDeleteConfirm(String name, String path);

  /// No description provided for @projectsDeleteListOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur aus Liste entfernen'**
  String get projectsDeleteListOnly;

  /// No description provided for @projectsDeleteProject.
  ///
  /// In de, this message translates to:
  /// **'Projekt loeschen'**
  String get projectsDeleteProject;

  /// No description provided for @projectsDeleteSuccessFull.
  ///
  /// In de, this message translates to:
  /// **'Projekt \"{name}\" wurde vollstaendig geloescht.'**
  String projectsDeleteSuccessFull(String name);

  /// No description provided for @projectsDeleteSuccessList.
  ///
  /// In de, this message translates to:
  /// **'Projekt \"{name}\" wurde aus der Liste entfernt.'**
  String projectsDeleteSuccessList(String name);

  /// No description provided for @projectsDeleteFailed.
  ///
  /// In de, this message translates to:
  /// **'Projekt konnte nicht geloescht werden: {error}'**
  String projectsDeleteFailed(String error);

  /// No description provided for @projectCreateTitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Projekt erstellen'**
  String get projectCreateTitle;

  /// No description provided for @projectCreateNameHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte Projektname eingeben.'**
  String get projectCreateNameHint;

  /// No description provided for @projectCreateFolderHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte Zielordner waehlen.'**
  String get projectCreateFolderHint;

  /// No description provided for @projectNoFolderSelected.
  ///
  /// In de, this message translates to:
  /// **'Kein Ordner ausgewaehlt'**
  String get projectNoFolderSelected;

  /// No description provided for @projectOpenTitle.
  ///
  /// In de, this message translates to:
  /// **'Projekt oeffnen'**
  String get projectOpenTitle;

  /// No description provided for @projectOpenFolderHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte Projektordner waehlen.'**
  String get projectOpenFolderHint;

  /// No description provided for @projectDetailNewBatch.
  ///
  /// In de, this message translates to:
  /// **'Neuer Batch'**
  String get projectDetailNewBatch;

  /// No description provided for @projectDetailBatches.
  ///
  /// In de, this message translates to:
  /// **'Batches'**
  String get projectDetailBatches;

  /// No description provided for @projectDetailPrompts.
  ///
  /// In de, this message translates to:
  /// **'Prompts'**
  String get projectDetailPrompts;

  /// No description provided for @projectDetailInput.
  ///
  /// In de, this message translates to:
  /// **'Input'**
  String get projectDetailInput;

  /// No description provided for @projectDetailNoBatches.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Batches vorhanden.'**
  String get projectDetailNoBatches;

  /// No description provided for @projectDetailNoPromptFiles.
  ///
  /// In de, this message translates to:
  /// **'Keine Prompt-Dateien gefunden.'**
  String get projectDetailNoPromptFiles;

  /// No description provided for @projectDetailNoInputFiles.
  ///
  /// In de, this message translates to:
  /// **'Keine Input-Dateien gefunden.'**
  String get projectDetailNoInputFiles;

  /// No description provided for @batchWizardItemsTitle.
  ///
  /// In de, this message translates to:
  /// **'Items laden'**
  String get batchWizardItemsTitle;

  /// No description provided for @batchWizardPromptsTitle.
  ///
  /// In de, this message translates to:
  /// **'Prompts waehlen'**
  String get batchWizardPromptsTitle;

  /// No description provided for @batchWizardChunksTitle.
  ///
  /// In de, this message translates to:
  /// **'Chunks'**
  String get batchWizardChunksTitle;

  /// No description provided for @batchWizardModelTitle.
  ///
  /// In de, this message translates to:
  /// **'Model konfigurieren'**
  String get batchWizardModelTitle;

  /// No description provided for @batchWizardConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Bestaetigen + starten'**
  String get batchWizardConfirmTitle;

  /// No description provided for @batchWizardStartBatch.
  ///
  /// In de, this message translates to:
  /// **'Batch starten'**
  String get batchWizardStartBatch;

  /// No description provided for @batchWizardTitle.
  ///
  /// In de, this message translates to:
  /// **'Batch Wizard - {projectName}'**
  String batchWizardTitle(String projectName);

  /// No description provided for @batchWizardSelectSource.
  ///
  /// In de, this message translates to:
  /// **'Bitte zuerst eine Eingabequelle waehlen.'**
  String get batchWizardSelectSource;

  /// No description provided for @batchWizardLoadItems.
  ///
  /// In de, this message translates to:
  /// **'Bitte Items laden, bevor du fortfaehrst.'**
  String get batchWizardLoadItems;

  /// No description provided for @batchWizardSelectPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens einen Prompt auswaehlen.'**
  String get batchWizardSelectPrompt;

  /// No description provided for @batchWizardSelectModel.
  ///
  /// In de, this message translates to:
  /// **'Bitte ein Model auswaehlen.'**
  String get batchWizardSelectModel;

  /// No description provided for @batchWizardConfirmPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Bitte die Datenschutz-Bestaetigung aktivieren.'**
  String get batchWizardConfirmPrivacy;

  /// No description provided for @batchWizardStartError.
  ///
  /// In de, this message translates to:
  /// **'Batch kann nicht gestartet werden.'**
  String get batchWizardStartError;

  /// No description provided for @batchWizardSaveError.
  ///
  /// In de, this message translates to:
  /// **'Batch konnte nicht gespeichert werden.'**
  String get batchWizardSaveError;

  /// No description provided for @batchWizardNotLoaded.
  ///
  /// In de, this message translates to:
  /// **'Batch Wizard konnte nicht geladen werden.'**
  String get batchWizardNotLoaded;

  /// No description provided for @batchWizardProjectNotLoaded.
  ///
  /// In de, this message translates to:
  /// **'Projekt nicht geladen.'**
  String get batchWizardProjectNotLoaded;

  /// No description provided for @batchWizardSaveChangesTitle.
  ///
  /// In de, this message translates to:
  /// **'Batch-Aenderungen speichern'**
  String get batchWizardSaveChangesTitle;

  /// No description provided for @batchWizardSaveChangesMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Batch ist bereits abgeschlossen oder fehlgeschlagen. Moechtest du ihn aktualisieren oder als neuen Batch speichern?'**
  String get batchWizardSaveChangesMessage;

  /// No description provided for @batchWizardUpdateExisting.
  ///
  /// In de, this message translates to:
  /// **'Bestehenden aktualisieren'**
  String get batchWizardUpdateExisting;

  /// No description provided for @batchWizardSaveAsNew.
  ///
  /// In de, this message translates to:
  /// **'Als neu speichern'**
  String get batchWizardSaveAsNew;

  /// No description provided for @batchWizardRunningNotEditable.
  ///
  /// In de, this message translates to:
  /// **'Laufende Batches koennen nicht bearbeitet werden.'**
  String get batchWizardRunningNotEditable;

  /// No description provided for @batchWizardGeneratedName.
  ///
  /// In de, this message translates to:
  /// **'Batch {timestamp}'**
  String batchWizardGeneratedName(String timestamp);

  /// No description provided for @batchWizardInactiveModelWarning.
  ///
  /// In de, this message translates to:
  /// **'Der ausgewaehlte Modellstatus ist \"{status}\". Fuer neue Laeufe sollte ein aktives Modell verwendet werden.'**
  String batchWizardInactiveModelWarning(String status);

  /// No description provided for @batchWizardItemsFallbackWarning.
  ///
  /// In de, this message translates to:
  /// **'Items konnten nicht aus der Eingabequelle geladen werden. Es wird die gespeicherte Item-Anzahl verwendet.'**
  String get batchWizardItemsFallbackWarning;

  /// No description provided for @batchDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Batch loeschen?'**
  String get batchDeleteTitle;

  /// No description provided for @batchDeleteDesc.
  ///
  /// In de, this message translates to:
  /// **'Batch \"{name}\" loeschen? Dies kann nicht rueckgaengig gemacht werden.'**
  String batchDeleteDesc(String name);

  /// No description provided for @itemsExcelCsv.
  ///
  /// In de, this message translates to:
  /// **'Excel/CSV'**
  String get itemsExcelCsv;

  /// No description provided for @itemsDocFolder.
  ///
  /// In de, this message translates to:
  /// **'Dokumenten-Ordner'**
  String get itemsDocFolder;

  /// No description provided for @itemsFileSource.
  ///
  /// In de, this message translates to:
  /// **'Dateiquelle'**
  String get itemsFileSource;

  /// No description provided for @itemsFolderSource.
  ///
  /// In de, this message translates to:
  /// **'Ordnerquelle'**
  String get itemsFolderSource;

  /// No description provided for @itemsSummary.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung:'**
  String get itemsSummary;

  /// No description provided for @itemsCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Items, {warnings} Warnungen'**
  String itemsCount(int count, int warnings);

  /// No description provided for @itemsIdColumn.
  ///
  /// In de, this message translates to:
  /// **'ID-Spalte'**
  String get itemsIdColumn;

  /// No description provided for @itemsIdLabel.
  ///
  /// In de, this message translates to:
  /// **'ID'**
  String get itemsIdLabel;

  /// No description provided for @itemsItemColumn.
  ///
  /// In de, this message translates to:
  /// **'Item-Spalte'**
  String get itemsItemColumn;

  /// No description provided for @itemsPreviewText.
  ///
  /// In de, this message translates to:
  /// **'Text (Vorschau)'**
  String get itemsPreviewText;

  /// No description provided for @chunksChunkSize.
  ///
  /// In de, this message translates to:
  /// **'Chunk-Groesse:'**
  String get chunksChunkSize;

  /// No description provided for @chunksRepetitions.
  ///
  /// In de, this message translates to:
  /// **'Wiederholungen:'**
  String get chunksRepetitions;

  /// No description provided for @chunksCalcChunks.
  ///
  /// In de, this message translates to:
  /// **'{items} Items / {chunkSize} = {chunks} Chunks'**
  String chunksCalcChunks(int items, int chunkSize, int chunks);

  /// No description provided for @chunksCalcCalls.
  ///
  /// In de, this message translates to:
  /// **'{chunks} Chunks x {prompts} Prompts x {reps} Wdh. = {calls} API-Calls'**
  String chunksCalcCalls(int chunks, int prompts, int reps, int calls);

  /// No description provided for @chunksTooltip.
  ///
  /// In de, this message translates to:
  /// **'Bei chunk_size > 1 werden mehrere Items gleichzeitig im Prompt gesendet. Dies spart API-Calls, kann aber die Qualitaet reduzieren.'**
  String get chunksTooltip;

  /// No description provided for @confirmItems.
  ///
  /// In de, this message translates to:
  /// **'Items:'**
  String get confirmItems;

  /// No description provided for @confirmSource.
  ///
  /// In de, this message translates to:
  /// **'Quelle:'**
  String get confirmSource;

  /// No description provided for @confirmPrompts.
  ///
  /// In de, this message translates to:
  /// **'Prompts:'**
  String get confirmPrompts;

  /// No description provided for @confirmChunkSize.
  ///
  /// In de, this message translates to:
  /// **'Chunk-Groesse:'**
  String get confirmChunkSize;

  /// No description provided for @confirmRepetitions.
  ///
  /// In de, this message translates to:
  /// **'Wiederholungen:'**
  String get confirmRepetitions;

  /// No description provided for @confirmTotalCalls.
  ///
  /// In de, this message translates to:
  /// **'Gesamt API-Calls:'**
  String get confirmTotalCalls;

  /// No description provided for @confirmModel.
  ///
  /// In de, this message translates to:
  /// **'Model:'**
  String get confirmModel;

  /// No description provided for @confirmPrivacyCheckbox.
  ///
  /// In de, this message translates to:
  /// **'Ich bestaetige, dass das Senden dieser Daten an den Cloud-Provider mit meinen Datenschutzanforderungen vereinbar ist.'**
  String get confirmPrivacyCheckbox;

  /// No description provided for @promptPreview.
  ///
  /// In de, this message translates to:
  /// **'Prompt-Vorschau'**
  String get promptPreview;

  /// No description provided for @promptSelectorAvailable.
  ///
  /// In de, this message translates to:
  /// **'Verfuegbar'**
  String get promptSelectorAvailable;

  /// No description provided for @promptSelectorSelected.
  ///
  /// In de, this message translates to:
  /// **'Ausgewaehlt'**
  String get promptSelectorSelected;

  /// No description provided for @promptImport.
  ///
  /// In de, this message translates to:
  /// **'Importieren'**
  String get promptImport;

  /// No description provided for @promptImportTooltip.
  ///
  /// In de, this message translates to:
  /// **'Prompt-Dateien von der Festplatte importieren'**
  String get promptImportTooltip;

  /// No description provided for @promptImportSuccess.
  ///
  /// In de, this message translates to:
  /// **'{count} Prompt(s) importiert.'**
  String promptImportSuccess(int count);

  /// No description provided for @promptImportSkipped.
  ///
  /// In de, this message translates to:
  /// **'Uebersprungen (existiert bereits): {names}'**
  String promptImportSkipped(String names);

  /// No description provided for @modelContext.
  ///
  /// In de, this message translates to:
  /// **'Kontext:'**
  String get modelContext;

  /// No description provided for @modelPriceLabel.
  ///
  /// In de, this message translates to:
  /// **'Preis (Input/Output je 1M):'**
  String get modelPriceLabel;

  /// No description provided for @execTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausfuehrung'**
  String get execTitle;

  /// No description provided for @execBatchTitle.
  ///
  /// In de, this message translates to:
  /// **'Batch-Ausfuehrung'**
  String get execBatchTitle;

  /// No description provided for @execBatchNameTitle.
  ///
  /// In de, this message translates to:
  /// **'Batch: {name}'**
  String execBatchNameTitle(String name);

  /// No description provided for @execBatchId.
  ///
  /// In de, this message translates to:
  /// **'Batch ID:'**
  String get execBatchId;

  /// No description provided for @execCurrentPromptName.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Prompt-Name:'**
  String get execCurrentPromptName;

  /// No description provided for @execCurrentModel.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Modell:'**
  String get execCurrentModel;

  /// No description provided for @execPreparingInput.
  ///
  /// In de, this message translates to:
  /// **'Konfiguration geladen. Eingabedaten werden vorbereitet...'**
  String get execPreparingInput;

  /// No description provided for @execRepetition.
  ///
  /// In de, this message translates to:
  /// **'Repetition:'**
  String get execRepetition;

  /// No description provided for @execPrompt.
  ///
  /// In de, this message translates to:
  /// **'Prompt:'**
  String get execPrompt;

  /// No description provided for @execChunk.
  ///
  /// In de, this message translates to:
  /// **'Chunk:'**
  String get execChunk;

  /// No description provided for @execCompletedCalls.
  ///
  /// In de, this message translates to:
  /// **'Completed Calls:'**
  String get execCompletedCalls;

  /// No description provided for @execFailedCalls.
  ///
  /// In de, this message translates to:
  /// **'Failed Calls:'**
  String get execFailedCalls;

  /// No description provided for @execInputTokens.
  ///
  /// In de, this message translates to:
  /// **'Input Tokens:'**
  String get execInputTokens;

  /// No description provided for @execOutputTokens.
  ///
  /// In de, this message translates to:
  /// **'Output Tokens:'**
  String get execOutputTokens;

  /// No description provided for @execResults.
  ///
  /// In de, this message translates to:
  /// **'Results:'**
  String get execResults;

  /// No description provided for @execLoadingConfig.
  ///
  /// In de, this message translates to:
  /// **'Batch-Konfiguration wird geladen...'**
  String get execLoadingConfig;

  /// No description provided for @execBatchNotFound.
  ///
  /// In de, this message translates to:
  /// **'Batch nicht gefunden.'**
  String get execBatchNotFound;

  /// No description provided for @execProjectNotFound.
  ///
  /// In de, this message translates to:
  /// **'Projekt nicht gefunden.'**
  String get execProjectNotFound;

  /// No description provided for @execInvalidConfig.
  ///
  /// In de, this message translates to:
  /// **'Ungueltige Batch-Konfiguration.'**
  String get execInvalidConfig;

  /// No description provided for @execNoItems.
  ///
  /// In de, this message translates to:
  /// **'Keine Items fuer die Ausfuehrung gefunden.'**
  String get execNoItems;

  /// No description provided for @execLoadingPrompts.
  ///
  /// In de, this message translates to:
  /// **'Prompts werden geladen...'**
  String get execLoadingPrompts;

  /// No description provided for @execNoPrompts.
  ///
  /// In de, this message translates to:
  /// **'Keine Prompt-Dateien aus der Batch-Konfiguration gefunden.'**
  String get execNoPrompts;

  /// No description provided for @execStartFailed.
  ///
  /// In de, this message translates to:
  /// **'Start fehlgeschlagen: {error}'**
  String execStartFailed(String error);

  /// No description provided for @execBatchStarted.
  ///
  /// In de, this message translates to:
  /// **'Batch gestartet.'**
  String get execBatchStarted;

  /// No description provided for @execReportsCreated.
  ///
  /// In de, this message translates to:
  /// **'Reports erstellt: {paths}'**
  String execReportsCreated(String paths);

  /// No description provided for @execReportsFailed.
  ///
  /// In de, this message translates to:
  /// **'Report-Generierung fehlgeschlagen: {error}'**
  String execReportsFailed(String error);

  /// No description provided for @execStatusIdle.
  ///
  /// In de, this message translates to:
  /// **'LEERLAUF'**
  String get execStatusIdle;

  /// No description provided for @execStatusStarting.
  ///
  /// In de, this message translates to:
  /// **'STARTET'**
  String get execStatusStarting;

  /// No description provided for @execStatusRunning.
  ///
  /// In de, this message translates to:
  /// **'LAEUFT'**
  String get execStatusRunning;

  /// No description provided for @execStatusPaused.
  ///
  /// In de, this message translates to:
  /// **'PAUSIERT'**
  String get execStatusPaused;

  /// No description provided for @execStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'ABGESCHLOSSEN'**
  String get execStatusCompleted;

  /// No description provided for @execStatusFailed.
  ///
  /// In de, this message translates to:
  /// **'FEHLER'**
  String get execStatusFailed;

  /// No description provided for @execProgressCalls.
  ///
  /// In de, this message translates to:
  /// **'{percent}%  |  {completed}/{total} Aufrufe'**
  String execProgressCalls(String percent, int completed, int total);

  /// No description provided for @modelsTitle.
  ///
  /// In de, this message translates to:
  /// **'Modelle'**
  String get modelsTitle;

  /// No description provided for @modelsRegistry.
  ///
  /// In de, this message translates to:
  /// **'Registry Models'**
  String get modelsRegistry;

  /// No description provided for @modelsCustom.
  ///
  /// In de, this message translates to:
  /// **'Custom Models'**
  String get modelsCustom;

  /// No description provided for @modelsDiscovered.
  ///
  /// In de, this message translates to:
  /// **'Discovered Models'**
  String get modelsDiscovered;

  /// No description provided for @modelsRegistryError.
  ///
  /// In de, this message translates to:
  /// **'Registry-Fehler: {error}'**
  String modelsRegistryError(String error);

  /// No description provided for @modelsNoRegistry.
  ///
  /// In de, this message translates to:
  /// **'Keine Registry-Models gefunden.'**
  String get modelsNoRegistry;

  /// No description provided for @modelsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'{count} Modelle'**
  String modelsCountLabel(int count);

  /// No description provided for @modelsNoCustom.
  ///
  /// In de, this message translates to:
  /// **'Keine Custom Model Overrides vorhanden.'**
  String get modelsNoCustom;

  /// No description provided for @modelsQueryProviders.
  ///
  /// In de, this message translates to:
  /// **'Provider abfragen'**
  String get modelsQueryProviders;

  /// No description provided for @modelsNoDiscovery.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Discovery-Daten.'**
  String get modelsNoDiscovery;

  /// No description provided for @modelsShowInactive.
  ///
  /// In de, this message translates to:
  /// **'Inaktive/veraltete Modelle anzeigen'**
  String get modelsShowInactive;

  /// No description provided for @modelsRegistryTileSubtitle.
  ///
  /// In de, this message translates to:
  /// **'ID: {id} | Kontext: {contextWindow} | USD/M in/out: {inputPrice}/{outputPrice}'**
  String modelsRegistryTileSubtitle(
    String id,
    int contextWindow,
    double inputPrice,
    double outputPrice,
  );

  /// No description provided for @modelsIdLabel.
  ///
  /// In de, this message translates to:
  /// **'ID:'**
  String get modelsIdLabel;

  /// No description provided for @modelsProviderLabel.
  ///
  /// In de, this message translates to:
  /// **'Provider:'**
  String get modelsProviderLabel;

  /// No description provided for @modelsStatusLabel.
  ///
  /// In de, this message translates to:
  /// **'Status:'**
  String get modelsStatusLabel;

  /// No description provided for @modelsDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Description:'**
  String get modelsDescriptionLabel;

  /// No description provided for @modelsContextWindow.
  ///
  /// In de, this message translates to:
  /// **'Context Window:'**
  String get modelsContextWindow;

  /// No description provided for @modelsMaxOutputTokens.
  ///
  /// In de, this message translates to:
  /// **'Max Output Tokens:'**
  String get modelsMaxOutputTokens;

  /// No description provided for @modelsCapabilities.
  ///
  /// In de, this message translates to:
  /// **'Capabilities'**
  String get modelsCapabilities;

  /// No description provided for @modelsCapabilityChat.
  ///
  /// In de, this message translates to:
  /// **'chat'**
  String get modelsCapabilityChat;

  /// No description provided for @modelsCapabilityVision.
  ///
  /// In de, this message translates to:
  /// **'vision'**
  String get modelsCapabilityVision;

  /// No description provided for @modelsCapabilityFn.
  ///
  /// In de, this message translates to:
  /// **'fn'**
  String get modelsCapabilityFn;

  /// No description provided for @modelsCapabilityJson.
  ///
  /// In de, this message translates to:
  /// **'json'**
  String get modelsCapabilityJson;

  /// No description provided for @modelsCapabilityReason.
  ///
  /// In de, this message translates to:
  /// **'reason'**
  String get modelsCapabilityReason;

  /// No description provided for @modelsPricingLabel.
  ///
  /// In de, this message translates to:
  /// **'Pricing (USD/M in,out): {inputPrice}, {outputPrice}'**
  String modelsPricingLabel(double inputPrice, double outputPrice);

  /// No description provided for @modelsCapabilitySummary.
  ///
  /// In de, this message translates to:
  /// **'chat={chat}, vision={vision}, functionCalling={functionCalling}, jsonMode={jsonMode}, streaming={streaming}, reasoning={reasoning}, extendedThinking={extendedThinking}'**
  String modelsCapabilitySummary(
    String chat,
    String vision,
    String functionCalling,
    String jsonMode,
    String streaming,
    String reasoning,
    String extendedThinking,
  );

  /// No description provided for @modelsParameterDetails.
  ///
  /// In de, this message translates to:
  /// **'{name}: supported={supported}, type={type}, min={min}, max={max}, default={defaultValue}, values={values}'**
  String modelsParameterDetails(
    String name,
    String supported,
    String type,
    String min,
    String max,
    String defaultValue,
    String values,
  );

  /// No description provided for @modelsParameters.
  ///
  /// In de, this message translates to:
  /// **'Parameters'**
  String get modelsParameters;

  /// No description provided for @modelsHideRegistryModelConfirm.
  ///
  /// In de, this message translates to:
  /// **'Modell \"{modelId}\" aus den Registry-Modellen ausblenden? Du kannst es spaeter unter Custom Models wiederherstellen, indem du den Override loeschst.'**
  String modelsHideRegistryModelConfirm(String modelId);

  /// No description provided for @modelsHideRegistryModelDone.
  ///
  /// In de, this message translates to:
  /// **'Modell \"{modelId}\" wurde ausgeblendet.'**
  String modelsHideRegistryModelDone(String modelId);

  /// No description provided for @modelsContextWindowField.
  ///
  /// In de, this message translates to:
  /// **'context_window'**
  String get modelsContextWindowField;

  /// No description provided for @modelsMaxOutputTokensField.
  ///
  /// In de, this message translates to:
  /// **'max_output_tokens'**
  String get modelsMaxOutputTokensField;

  /// No description provided for @modelsNoParameterDefinitions.
  ///
  /// In de, this message translates to:
  /// **'Keine Parameter-Definitionen gefunden.'**
  String get modelsNoParameterDefinitions;

  /// No description provided for @modelsRawJson.
  ///
  /// In de, this message translates to:
  /// **'JSON'**
  String get modelsRawJson;

  /// No description provided for @modelsContextWindowPositive.
  ///
  /// In de, this message translates to:
  /// **'context_window muss eine positive Ganzzahl sein.'**
  String get modelsContextWindowPositive;

  /// No description provided for @modelsMaxOutputTokensPositive.
  ///
  /// In de, this message translates to:
  /// **'max_output_tokens muss eine positive Ganzzahl sein.'**
  String get modelsMaxOutputTokensPositive;

  /// No description provided for @modelsParameterMeta.
  ///
  /// In de, this message translates to:
  /// **'type={type}   min={min}   max={max}'**
  String modelsParameterMeta(String type, String min, String max);

  /// No description provided for @modelsDefaultLabel.
  ///
  /// In de, this message translates to:
  /// **'default'**
  String get modelsDefaultLabel;

  /// No description provided for @modelsApiNameOptional.
  ///
  /// In de, this message translates to:
  /// **'api_name (optional)'**
  String get modelsApiNameOptional;

  /// No description provided for @modelsInvalidIntegerDefault.
  ///
  /// In de, this message translates to:
  /// **'Ungueltiger Integer-Default fuer Parameter \"{key}\".'**
  String modelsInvalidIntegerDefault(String key);

  /// No description provided for @modelsInvalidFloatDefault.
  ///
  /// In de, this message translates to:
  /// **'Ungueltiger Float-Default fuer Parameter \"{key}\".'**
  String modelsInvalidFloatDefault(String key);

  /// No description provided for @modelsEditOverride.
  ///
  /// In de, this message translates to:
  /// **'Override bearbeiten:'**
  String get modelsEditOverride;

  /// No description provided for @modelsOverrideJsonLabel.
  ///
  /// In de, this message translates to:
  /// **'overrideJson'**
  String get modelsOverrideJsonLabel;

  /// No description provided for @modelsJsonMustBeObject.
  ///
  /// In de, this message translates to:
  /// **'JSON muss ein Objekt sein.'**
  String get modelsJsonMustBeObject;

  /// No description provided for @modelsInvalidJson.
  ///
  /// In de, this message translates to:
  /// **'Ungueltiges JSON: {error}'**
  String modelsInvalidJson(String error);

  /// No description provided for @modelsCreateCustomTitle.
  ///
  /// In de, this message translates to:
  /// **'Custom Model erstellen'**
  String get modelsCreateCustomTitle;

  /// No description provided for @modelsCreateCustomModelId.
  ///
  /// In de, this message translates to:
  /// **'modelId'**
  String get modelsCreateCustomModelId;

  /// No description provided for @modelsCreateCustomProvider.
  ///
  /// In de, this message translates to:
  /// **'provider'**
  String get modelsCreateCustomProvider;

  /// No description provided for @modelsModelIdRequired.
  ///
  /// In de, this message translates to:
  /// **'modelId ist erforderlich.'**
  String get modelsModelIdRequired;

  /// No description provided for @modelsModelNotFound.
  ///
  /// In de, this message translates to:
  /// **'Modell nicht gefunden.'**
  String get modelsModelNotFound;

  /// No description provided for @modelsDiscoveryNotReachable.
  ///
  /// In de, this message translates to:
  /// **'Nicht erreichbar unter {baseUrl}'**
  String modelsDiscoveryNotReachable(String baseUrl);

  /// No description provided for @modelsDiscoveryNoModels.
  ///
  /// In de, this message translates to:
  /// **'Keine Modelle gefunden unter {baseUrl}'**
  String modelsDiscoveryNoModels(String baseUrl);

  /// No description provided for @modelsDiscoveryFailedAt.
  ///
  /// In de, this message translates to:
  /// **'Discovery fehlgeschlagen unter {baseUrl}: {error}'**
  String modelsDiscoveryFailedAt(String baseUrl, String error);

  /// No description provided for @modelsCustomModelDescription.
  ///
  /// In de, this message translates to:
  /// **'Custom Model aus dem Model Manager hinzugefuegt'**
  String get modelsCustomModelDescription;

  /// No description provided for @modelsOverrideSaved.
  ///
  /// In de, this message translates to:
  /// **'Override gespeichert.'**
  String get modelsOverrideSaved;

  /// No description provided for @modelsOverrideDeleted.
  ///
  /// In de, this message translates to:
  /// **'Override geloescht.'**
  String get modelsOverrideDeleted;

  /// No description provided for @modelsDiscoveryFailed.
  ///
  /// In de, this message translates to:
  /// **'Discovery fehlgeschlagen: {error}'**
  String modelsDiscoveryFailed(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In de, this message translates to:
  /// **'Sicherheit'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionAdvanced.
  ///
  /// In de, this message translates to:
  /// **'Erweitert'**
  String get settingsSectionAdvanced;

  /// No description provided for @settingsSectionReset.
  ///
  /// In de, this message translates to:
  /// **'Zuruecksetzen'**
  String get settingsSectionReset;

  /// No description provided for @settingsChangePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort aendern'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordDesc.
  ///
  /// In de, this message translates to:
  /// **'Master-Passwort fuer die Verschluesselung'**
  String get settingsChangePasswordDesc;

  /// No description provided for @settingsManageProviders.
  ///
  /// In de, this message translates to:
  /// **'API-Provider verwalten'**
  String get settingsManageProviders;

  /// No description provided for @settingsManageProvidersDesc.
  ///
  /// In de, this message translates to:
  /// **'API-Keys hinzufuegen, bearbeiten oder loeschen'**
  String get settingsManageProvidersDesc;

  /// No description provided for @settingsStrictLocalMode.
  ///
  /// In de, this message translates to:
  /// **'Strict Local Mode'**
  String get settingsStrictLocalMode;

  /// No description provided for @settingsStrictLocalModeDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur lokale Provider (Ollama, LM Studio) erlauben. Cloud-Provider werden deaktiviert.'**
  String get settingsStrictLocalModeDesc;

  /// No description provided for @settingsCheckpointInterval.
  ///
  /// In de, this message translates to:
  /// **'Checkpoint-Intervall'**
  String get settingsCheckpointInterval;

  /// No description provided for @settingsCheckpointIntervalDesc.
  ///
  /// In de, this message translates to:
  /// **'Alle {count} API-Calls wird ein Checkpoint gespeichert'**
  String settingsCheckpointIntervalDesc(int count);

  /// No description provided for @settingsResetApp.
  ///
  /// In de, this message translates to:
  /// **'App zuruecksetzen'**
  String get settingsResetApp;

  /// No description provided for @settingsResetAppDesc.
  ///
  /// In de, this message translates to:
  /// **'Alle Einstellungen, Provider und API-Keys loeschen. Projekte bleiben erhalten.'**
  String get settingsResetAppDesc;

  /// No description provided for @settingsPasswordChanged.
  ///
  /// In de, this message translates to:
  /// **'Passwort erfolgreich geaendert'**
  String get settingsPasswordChanged;

  /// No description provided for @settingsMinPasswordLength.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get settingsMinPasswordLength;

  /// No description provided for @settingsPasswordMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwoerter stimmen nicht ueberein'**
  String get settingsPasswordMismatch;

  /// No description provided for @settingsWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Passwort ist falsch'**
  String get settingsWrongPassword;

  /// No description provided for @settingsDecryptKeysFailed.
  ///
  /// In de, this message translates to:
  /// **'Vorhandene Schluessel konnten nicht entschluesselt werden. Passwort wurde nicht geaendert.'**
  String get settingsDecryptKeysFailed;

  /// No description provided for @settingsReEncryptionFailed.
  ///
  /// In de, this message translates to:
  /// **'Neuverschluesselung fehlgeschlagen. Passwort wurde nicht geaendert.'**
  String get settingsReEncryptionFailed;

  /// No description provided for @settingsProviderTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Provider'**
  String get settingsProviderTitle;

  /// No description provided for @settingsProviderAdd.
  ///
  /// In de, this message translates to:
  /// **'Provider hinzufuegen'**
  String get settingsProviderAdd;

  /// No description provided for @settingsProviderAddTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Provider hinzufuegen'**
  String get settingsProviderAddTitle;

  /// No description provided for @settingsProviderEditTitle.
  ///
  /// In de, this message translates to:
  /// **'Provider bearbeiten: {name}'**
  String settingsProviderEditTitle(String name);

  /// No description provided for @settingsProviderName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get settingsProviderName;

  /// No description provided for @settingsProviderType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get settingsProviderType;

  /// No description provided for @settingsProviderBaseUrl.
  ///
  /// In de, this message translates to:
  /// **'Base-URL'**
  String get settingsProviderBaseUrl;

  /// No description provided for @settingsProviderApiKey.
  ///
  /// In de, this message translates to:
  /// **'API-Key'**
  String get settingsProviderApiKey;

  /// No description provided for @settingsProviderApiKeyLocalOptional.
  ///
  /// In de, this message translates to:
  /// **'Optional fuer lokale Provider.'**
  String get settingsProviderApiKeyLocalOptional;

  /// No description provided for @settingsProviderApiKeyKeepHint.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, um den gespeicherten Key zu behalten.'**
  String get settingsProviderApiKeyKeepHint;

  /// No description provided for @settingsProviderApiKeyRequiredHint.
  ///
  /// In de, this message translates to:
  /// **'Fuer Cloud-Provider erforderlich.'**
  String get settingsProviderApiKeyRequiredHint;

  /// No description provided for @settingsProviderClearApiKey.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherten API-Key loeschen'**
  String get settingsProviderClearApiKey;

  /// No description provided for @settingsProviderEnabled.
  ///
  /// In de, this message translates to:
  /// **'Aktiviert'**
  String get settingsProviderEnabled;

  /// No description provided for @settingsProviderKeyStored.
  ///
  /// In de, this message translates to:
  /// **'API-Key gespeichert'**
  String get settingsProviderKeyStored;

  /// No description provided for @settingsProviderKeyMissing.
  ///
  /// In de, this message translates to:
  /// **'Kein API-Key'**
  String get settingsProviderKeyMissing;

  /// No description provided for @settingsProviderNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Providernamen eingeben.'**
  String get settingsProviderNameRequired;

  /// No description provided for @settingsProviderBaseUrlRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Base-URL eingeben.'**
  String get settingsProviderBaseUrlRequired;

  /// No description provided for @settingsProviderApiKeyRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen API-Key fuer diesen Providertyp eingeben.'**
  String get settingsProviderApiKeyRequired;

  /// No description provided for @settingsProviderEncryptionLocked.
  ///
  /// In de, this message translates to:
  /// **'API-Key kann nicht gespeichert werden, solange die App gesperrt ist.'**
  String get settingsProviderEncryptionLocked;

  /// No description provided for @settingsProviderAdded.
  ///
  /// In de, this message translates to:
  /// **'Provider hinzugefuegt.'**
  String get settingsProviderAdded;

  /// No description provided for @settingsProviderUpdated.
  ///
  /// In de, this message translates to:
  /// **'Provider aktualisiert.'**
  String get settingsProviderUpdated;

  /// No description provided for @settingsProviderSaveError.
  ///
  /// In de, this message translates to:
  /// **'Provider konnte nicht gespeichert werden: {error}'**
  String settingsProviderSaveError(String error);

  /// No description provided for @settingsNoProviders.
  ///
  /// In de, this message translates to:
  /// **'Keine Provider konfiguriert'**
  String get settingsNoProviders;

  /// No description provided for @settingsDeleteProvider.
  ///
  /// In de, this message translates to:
  /// **'Provider loeschen?'**
  String get settingsDeleteProvider;

  /// No description provided for @settingsDeleteProviderDesc.
  ///
  /// In de, this message translates to:
  /// **'Provider \"{name}\" und den gespeicherten API-Key loeschen?'**
  String settingsDeleteProviderDesc(String name);

  /// No description provided for @settingsResetTitle.
  ///
  /// In de, this message translates to:
  /// **'App zuruecksetzen?'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetDesc.
  ///
  /// In de, this message translates to:
  /// **'Alle Einstellungen, Provider und API-Keys werden geloescht. Projekt-Ordner auf der Festplatte bleiben erhalten.\n\nDiese Aktion kann nicht rueckgaengig gemacht werden.'**
  String get settingsResetDesc;

  /// No description provided for @costTitle.
  ///
  /// In de, this message translates to:
  /// **'Kosten-Vorschau'**
  String get costTitle;

  /// No description provided for @costInputTokens.
  ///
  /// In de, this message translates to:
  /// **'Input-Tokens:'**
  String get costInputTokens;

  /// No description provided for @costOutputTokens.
  ///
  /// In de, this message translates to:
  /// **'Output-Tokens:'**
  String get costOutputTokens;

  /// No description provided for @costApiCalls.
  ///
  /// In de, this message translates to:
  /// **'API-Calls:'**
  String get costApiCalls;

  /// No description provided for @costTotal.
  ///
  /// In de, this message translates to:
  /// **'Gesamt:'**
  String get costTotal;

  /// No description provided for @costDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Schaetzung basierend auf modellnahem GPT-4o/o1-Tokenizer.'**
  String get costDisclaimer;

  /// No description provided for @privacyTitle.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz-Hinweis'**
  String get privacyTitle;

  /// No description provided for @privacyMessage.
  ///
  /// In de, this message translates to:
  /// **'Sie senden Daten an {provider} ({region}). DSGVO und interne Richtlinien beachten.'**
  String privacyMessage(String provider, String region);

  /// No description provided for @privacyDontShowAgain.
  ///
  /// In de, this message translates to:
  /// **'Nicht mehr anzeigen'**
  String get privacyDontShowAgain;

  /// No description provided for @privacyUnderstood.
  ///
  /// In de, this message translates to:
  /// **'Verstanden'**
  String get privacyUnderstood;

  /// No description provided for @resumeTitle.
  ///
  /// In de, this message translates to:
  /// **'Checkpoint gefunden'**
  String get resumeTitle;

  /// No description provided for @resumeSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert:'**
  String get resumeSaved;

  /// No description provided for @resumeProgress.
  ///
  /// In de, this message translates to:
  /// **'Fortschritt:'**
  String get resumeProgress;

  /// No description provided for @resumeCalls.
  ///
  /// In de, this message translates to:
  /// **'Calls:'**
  String get resumeCalls;

  /// No description provided for @resumeTokens.
  ///
  /// In de, this message translates to:
  /// **'Tokens:'**
  String get resumeTokens;

  /// No description provided for @resumeRestart.
  ///
  /// In de, this message translates to:
  /// **'Neu starten'**
  String get resumeRestart;

  /// No description provided for @resumeContinue.
  ///
  /// In de, this message translates to:
  /// **'Fortsetzen'**
  String get resumeContinue;

  /// No description provided for @logLevelAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get logLevelAll;

  /// No description provided for @logLevelLabel.
  ///
  /// In de, this message translates to:
  /// **'Level:'**
  String get logLevelLabel;

  /// No description provided for @logLevelInfo.
  ///
  /// In de, this message translates to:
  /// **'INFO'**
  String get logLevelInfo;

  /// No description provided for @logLevelWarn.
  ///
  /// In de, this message translates to:
  /// **'WARN'**
  String get logLevelWarn;

  /// No description provided for @logLevelError.
  ///
  /// In de, this message translates to:
  /// **'ERROR'**
  String get logLevelError;

  /// No description provided for @noSourceSelected.
  ///
  /// In de, this message translates to:
  /// **'Keine Quelle gewaehlt'**
  String get noSourceSelected;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorGeneric(String error);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SDe();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
