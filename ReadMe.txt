(Donload and copy "googlechromestandaloneenterprise64.msi" to the Source folder)
The package remove all types of Chrome installation (user/system & MSI/EXE).
The installation command can be used as the command to repair in SCCM.

Policies which were added to the MST file:

SOFTWARE\Policies\Google\Chrome:
⦁	BackgroundModeEnabled=1
⦁	DefaultSearchProviderEnabled=1
⦁	UserFeedbackAllowed=0
⦁	AdsSettingForIntrusiveAdsSites=2
⦁	AllowDeletingBrowserHistory=0
⦁	AutofillCreditCardEnabled=0
⦁	BrowserAddPersonEnabled=0
⦁	BrowserSignin=0
⦁	ChromeCleanupReportingEnabled=0
⦁	DefaultBrowserSettingEnabled=0
⦁	AllowDinosaurEasterEgg=0
⦁	ImportAutofillFormData=0
⦁	ImportBookmarks=0
⦁	ImportHistory=0
⦁	ImportHomepage=0
⦁	ImportSavedPasswords=0
⦁	ImportSearchEngine=0
⦁	LocalDiscoveryEnabled=0
⦁	NTPCustomBackgroundEnabled=0
⦁	PaymentMethodQueryEnabled=0
⦁	PrivacySandboxAdMeasurementEnabled=0
⦁	PrivacySandboxAdTopicsEnabled=0
⦁	PrivacySandboxPromptEnabled=0
⦁	PrivacySandboxSiteEnabledAdsEnabled=0
⦁	PromotionalTabsEnabled=0
⦁	RemoteAccessHostAllowFileTransfer=0
⦁	SavingBrowserHistoryDisabled=0
⦁	AbusiveExperienceInterventionEnforce=1
⦁	SafeBrowsingEnabled=1
⦁	SSLErrorOverrideAllowed=1
⦁	ShowHomeButton=1

SOFTWARE\Policies\Google\Update:
⦁	AutoUpdateCheckPeriodMinutes=0
⦁	Update{8A69D345-D564-463C-AFF1-A69D9E530F96}=0
⦁	DisableAutoUpdateChecksCheckboxValue=0
⦁	UpdateDefault=0

SOFTWARE\Wow6432Node\Google\Update:
⦁	AutoUpdateCheckPeriodMinutes=0
⦁	DisableAutoUpdateChecksCheckboxValue=1
⦁	UpdateDefault=0

Chrome Applications (Google Drive, Sheets, Youtube, Docs, Gmail, Slides and Google Docs Offline) were blocked by a policy (included in the MST file):

SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist:
⦁	1=kefjledonklijopmnomlcbpllchaibag
⦁	2=fmgjjmmmlfnkbppncabfkddbjimcfncm
⦁	3=mpnpojknpmmopombnjdcgaaiekajbnjb
⦁	4=agimnkijcaahngcdmfeangaknmldooml
⦁	5=fhihpiojkbmbpdjeoajapmgkhlnakfjf
⦁	6=aghbiahbpaijignceidepookljebhfak
⦁	7=ghbmnnjooekpmoecnnnilnnbdlolhkhi
