﻿#Если Клиент Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Заполняет табличный документ
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом,
//
Процедура СформироватьОтчет(ДокументРезультат) Экспорт

	Отказ = Ложь;
	
	// Проверка параметров
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана организация!", Отказ);
	КонецЕсли; 
	Если НЕ ЗначениеЗаполнено(НалоговыйПериод) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указан налоговый период!", Отказ);
	КонецЕсли; 
	Если НЕ ЗначениеЗаполнено(Физлицо) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указан работник организации!", Отказ);
	КонецЕсли; 
	Если Отказ Тогда
		Возврат ;
	КонецЕсли; 	
	
	ДокументРезультат.Очистить();
	Макет =	ПолучитьМакет("ИндивидуальнаяКарточкаЕСН");

	// Расчет вычисляемых параметров
	ДатаНачалаНП = НачалоГода(Дата(НалоговыйПериод,1,1));
	ДатаКонцаНП = КонецГода(Дата(НалоговыйПериод,1,1));
	ГоловнаяОрганизация = ОбщегоНазначения.ГоловнаяОрганизация(Организация);
	
	// Создание запроса и установка всех необходимых параметров
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц; 
	
	Запрос.УстановитьПараметр("ГоловнаяОрганизация", ГоловнаяОрганизация);
	Запрос.УстановитьПараметр("ФизЛицо", ФизЛицо);
	Запрос.УстановитьПараметр("НачалоНП", ДатаНачалаНП);
	Запрос.УстановитьПараметр("ГодНП", НалоговыйПериод);
	Запрос.УстановитьПараметр("КонецНП", ДатаКонцаНП);
	Запрос.УстановитьПараметр("ВидАдресаРегистрации" , Справочники.ВидыКонтактнойИнформации.ЮрАдресФизЛица);
	Запрос.УстановитьПараметр("ВидАдресаФактический" , Справочники.ВидыКонтактнойИнформации.ФактАдресФизЛица);
    СписокСтруктурныхПодразделений = ОбщегоНазначения.ПолучитьСписокОбособленныхПодразделенийОрганизации(ГоловнаяОрганизация);
	СписокСтруктурныхПодразделений.Добавить(ГоловнаяОрганизация);
	Запрос.УстановитьПараметр("СписокСтруктурныхПодразделений", СписокСтруктурныхПодразделений);
	
		
	// ---------------------------------------------------------------------------
	// Тексты запросов
	//

	// Сформируем текст запроса выборки месяцев налогового периода
	МесяцыНПТекст = "ВЫБРАТЬ 1 КАК МЕСЯЦ ПОМЕСТИТЬ ВТМесяцыНП";
	Для Сч = 2 По 12 Цикл
		МесяцыНПТекст = МесяцыНПТекст +" ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ " + Сч;
	КонецЦикла;
	
	Запрос.Текст = МесяцыНПТекст;
	Запрос.Выполнить();
	
	// первый месяц
	КонецМесяца = КонецМесяца(ДатаНачалаНП);
	ПериодыТекст = "ВЫБРАТЬ ДАТАВРЕМЯ(" + Формат(КонецМесяца,"ДФ=гггг,М,д,Ч,м,с") + ") КАК Период ПОМЕСТИТЬ ВТПериоды";
	// прибавим остальные месяцы
	Для Сч = 2 По 12 Цикл
		КонецМесяца = КонецМесяца(КонецМесяца+1);
		ПериодыТекст = ПериодыТекст +" ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ ДАТАВРЕМЯ(" + Формат(КонецМесяца,"ДФ=гггг,М,д,Ч,м,с") + ")";
	КонецЦикла;
	
	Запрос.Текст = ПериодыТекст;
	Запрос.Выполнить();

	//-----------------------------------------------------------------------------
	// ВЫБОРКА СВЕДЕНИЙ О ФИЗЛИЦЕ 
	// 	
	
	ДанныеОФизлицеТекст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЕСТЬNULL(ФИОФизЛица.Фамилия + "" "" + ФИОФизЛица.Имя + "" "" + ФИОФизЛица.Отчество, ДанныеОФизЛице.Наименование) КАК ФИО,
	|	ДанныеОФизЛице.ИНН КАК ИНН,
	|	ДанныеОФизЛице.СтраховойНомерПФР КАК СтраховойНомерПФР,
	|	ВЫБОР
	|		КОГДА ДанныеОФизЛице.Пол = ЗНАЧЕНИЕ(Перечисление.ПолФизическихЛиц.Мужской)
	|			ТОГДА ""М""
	|		ИНАЧЕ ""Ж""
	|	КОНЕЦ КАК Пол,
	|	ДанныеОФизЛице.ДатаРождения КАК ДатаРождения,
	|	ЕСТЬNULL(ГражданствоФизЛица.Страна.Наименование, ""Россия"") КАК Гражданство,
	|	ПаспортныеДанныеФизЛица.ДокументСерия КАК ДокументСерия,
	|	ПаспортныеДанныеФизЛица.ДокументНомер КАК ДокументНомер,
	|	ПаспортныеДанныеФизЛица.ДокументДатаВыдачи,
	|	ВЫРАЗИТЬ(ПаспортныеДанныеФизЛица.ДокументКемВыдан КАК СТРОКА(300)) КАК ДокументКемКогдаВыдан,
	|	"","" + АдресаРегистрации.Поле1 + "","" + АдресаРегистрации.Поле2 + "","" + АдресаРегистрации.Поле3 + "","" + АдресаРегистрации.Поле4 + "","" + АдресаРегистрации.Поле5 + "","" + АдресаРегистрации.Поле6 + "","" + АдресаРегистрации.Поле7 + "","" + АдресаРегистрации.Поле8 + "","" + АдресаРегистрации.Поле9 КАК АдресРегистрации,
	|	"","" + АдресаФактические.Поле1 + "","" + АдресаФактические.Поле2 + "","" + АдресаФактические.Поле3 + "","" + АдресаФактические.Поле4 + "","" + АдресаФактические.Поле5 + "","" + АдресаФактические.Поле6 + "","" + АдресаФактические.Поле7 + "","" + АдресаФактические.Поле8 + "","" + АдресаФактические.Поле9 КАК АдресФактический,
	|	СведенияОбИнвалидности.ГруппаИнвалидности,
	|	СведенияОбИнвалидности.СерияСправки КАК СерияСправкиИнвалидности,
	|	СведенияОбИнвалидности.НомерСправки КАК НомерСправкиИнвалидности,
	|	РаботникиОрганизации.Должность.Наименование КАК Должность,
	|	ВЫБОР
	|		КОГДА РаботникиОрганизации.Сотрудник ЕСТЬ NULL 
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК ТрудовойДоговор,
	|	ВЫБОР
	|		КОГДА РаботникиОрганизации.Сотрудник ЕСТЬ НЕ NULL 
	|			ТОГДА ПриемНаРаботуВОрганизациюРаботникиОрганизации.Ссылка.Номер
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК НомерДоговора,
	|	ВЫБОР
	|		КОГДА РаботникиОрганизации.Сотрудник ЕСТЬ НЕ NULL 
	|			ТОГДА ДатыНазначенияНаДолжность.ДатаНазначенияНаДолжность
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК ДатаНазначенияНаДолжность
	|ИЗ
	|	Справочник.ФизическиеЛица КАК ДанныеОФизЛице
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ФИОФизЛиц.СрезПоследних(&КонецНП, ФизЛицо = &ФизЛицо) КАК ФИОФизЛица
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций.СрезПоследних(
	|				&КонецНП,
	|				Сотрудник.ФизЛицо = &ФизЛицо
	|					И Организация = &ГоловнаяОрганизация
	|					И Сотрудник.ВидЗанятости <> ЗНАЧЕНИЕ(Перечисление.ВидыЗанятостиВОрганизации.ВнутреннееСовместительство)
	|					И ПричинаИзмененияСостояния = ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.ПриемНаРаботу)) КАК РаботникиОрганизации
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПриемНаРаботуВОрганизацию.РаботникиОрганизации КАК ПриемНаРаботуВОрганизациюРаботникиОрганизации
	|			ПО (ПриемНаРаботуВОрганизациюРаботникиОрганизации.Ссылка = РаботникиОрганизации.Регистратор)
	|				И (ПриемНаРаботуВОрганизациюРаботникиОрганизации.Сотрудник = РаботникиОрганизации.Сотрудник)
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций.СрезПоследних(
	|					&КонецНП,
	|					Сотрудник.ФизЛицо = &ФизЛицо
	|						И Организация = &ГоловнаяОрганизация
	|						И Сотрудник.ВидЗанятости <> ЗНАЧЕНИЕ(Перечисление.ВидыЗанятостиВОрганизации.ВнутреннееСовместительство)) КАК ДолжностиРаботниковОрганизации
	|				ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|					РаботникиОрганизацийСрезПоследних.Сотрудник КАК Сотрудник,
	|					МИНИМУМ(ДатыНазначенияНаДолжность.Период) КАК ДатаНазначенияНаДолжность
	|				ИЗ
	|					РегистрСведений.РаботникиОрганизаций.СрезПоследних(
	|							&КонецНП,
	|							Сотрудник.ФизЛицо = &ФизЛицо
	|								И Организация = &ГоловнаяОрганизация
	|								И Сотрудник.ВидЗанятости <> ЗНАЧЕНИЕ(Перечисление.ВидыЗанятостиВОрганизации.ВнутреннееСовместительство)) КАК РаботникиОрганизацийСрезПоследних
	|						ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций КАК ДатыНазначенияНаДолжность
	|						ПО РаботникиОрганизацийСрезПоследних.Сотрудник = ДатыНазначенияНаДолжность.Сотрудник
	|							И РаботникиОрганизацийСрезПоследних.Должность = ДатыНазначенияНаДолжность.Должность
	|				
	|				СГРУППИРОВАТЬ ПО
	|					РаботникиОрганизацийСрезПоследних.Сотрудник) КАК ДатыНазначенияНаДолжность
	|				ПО ДолжностиРаботниковОрганизации.Сотрудник = ДатыНазначенияНаДолжность.Сотрудник
	|			ПО РаботникиОрганизации.Сотрудник = ДолжностиРаботниковОрганизации.Сотрудник
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПаспортныеДанныеФизЛиц.СрезПоследних(&КонецНП, ФизЛицо = &ФизЛицо) КАК ПаспортныеДанныеФизЛица
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ГражданствоФизЛиц.СрезПоследних(&КонецНП, ФизЛицо = &ФизЛицо) КАК ГражданствоФизЛица
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КонтактнаяИнформация КАК АдресаРегистрации
	|		ПО (АдресаРегистрации.Объект = &ФизЛицо)
	|			И (АдресаРегистрации.Вид = &ВидАдресаРегистрации)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КонтактнаяИнформация КАК АдресаФактические
	|		ПО (АдресаФактические.Объект = &ФизЛицо)
	|			И (АдресаФактические.Вид = &ВидАдресаФактический)
	|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			МАКСИМУМ(СведенияОбИнвалидностиФизЛиц.Период) КАК Период
	|		ИЗ
	|			РегистрСведений.СведенияОбИнвалидностиФизлиц КАК СведенияОбИнвалидностиФизЛиц
	|		ГДЕ
	|			СведенияОбИнвалидностиФизЛиц.Физлицо = &ФизЛицо
	|			И СведенияОбИнвалидностиФизЛиц.Период <= &КонецНП) КАК ДатаСведенийОбИнвалидности
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОбИнвалидностиФизлиц КАК СведенияОбИнвалидности
	|		ПО (СведенияОбИнвалидности.Физлицо = &ФизЛицо)
	|			И (СведенияОбИнвалидности.Период = ДатаСведенийОбИнвалидности.Период)
	|			И (СведенияОбИнвалидности.Инвалидность)
	|ГДЕ
	|	ДанныеОФизЛице.Ссылка = &ФизЛицо
	|
	|УПОРЯДОЧИТЬ ПО
	|	РаботникиОрганизации.Период УБЫВ";
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСНСведенияОДоходах.ФизЛицо КАК ФизЛицо
	|ПОМЕСТИТЬ ВТФизлицаБезНалоговойБазы
	|ИЗ
	|	РегистрНакопления.ЕСНСведенияОДоходах КАК ЕСНСведенияОДоходах
	|ГДЕ
	|	ЕСНСведенияОДоходах.ФизЛицо = &ФизЛицо
	|	И ЕСНСведенияОДоходах.Период МЕЖДУ &НачалоНП И &КонецНП
	|	И ЕСНСведенияОДоходах.Организация = &ГоловнаяОрганизация
	|	И (НЕ ЕСНСведенияОДоходах.ОблагаетсяЕНВД)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЕСНСведенияОДоходах.ФизЛицо
	|
	|ИМЕЮЩИЕ
	|	СУММА(ВЫБОР
	|			КОГДА ЕСНСведенияОДоходах.КодДоходаЕСН.ВходитВБазуФОМС
	|				ТОГДА ЕСНСведенияОДоходах.Результат - ЕСНСведенияОДоходах.Скидка
	|			ИНАЧЕ 0
	|		КОНЕЦ) < 0
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ФизЛицо";
	Запрос.Выполнить();
									   
	// ДоходыПоМесяцамКодамТекст
	// Таблица доходов ЕСН по Месяцам налогового периода и кодам дохода
	// Поля:
	//		Месяц
	//		КодДоходаЕСН
	//		Результат
	//		Скидка
	// Описание:
	// 	Выбираем зарегистрированные доходы из ЕСНСведенияОДоходах 	
	//  Запрос выполняется для списка обособленных подразделений.
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МЕСЯЦ(ЕСНСведенияОДоходах.Период) КАК Месяц,
	|	ЕСНСведенияОДоходах.КодДоходаЕСН,
	|	СУММА(ЕСНСведенияОДоходах.Результат) КАК Результат,
	|	СУММА(ЕСНСведенияОДоходах.Скидка) КАК Скидка
	|ПОМЕСТИТЬ ВТДоходыПоМесяцамКодам
	|ИЗ
	|	РегистрНакопления.ЕСНСведенияОДоходах КАК ЕСНСведенияОДоходах
	|ГДЕ
	|	ЕСНСведенияОДоходах.ФизЛицо = &ФизЛицо
	|	И ЕСНСведенияОДоходах.Организация = &ГоловнаяОрганизация
	|	И ЕСНСведенияОДоходах.Период МЕЖДУ &НачалоНП И &КонецНП
	|	И (НЕ ЕСНСведенияОДоходах.ОблагаетсяЕНВД)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЕСНСведенияОДоходах.КодДоходаЕСН,
	|	МЕСЯЦ(ЕСНСведенияОДоходах.Период)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";
	Запрос.Выполнить();
   
	// ДанныеОПравеНаПенсию
	// Таблица Таблица Данные о праве на пенсию: - таблица это список иностранцев и периодов
	// Поля:
	//		Физлицо, 
	//		Месяц - месяц налогового периода
	// 
	// Описание:
	//	Выбираем Из Списка периодов
	//	Внутреннее соединение с ГражданствоФизЛиц.СрезПоследних
	//  по равенству периодов
	//  условие: что физлицо - не имеет права на пенсию
	//
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МЕСЯЦ(Периоды.Период) КАК Месяц,
	|	ГражданствоФизЛиц.ФизЛицо
	|ПОМЕСТИТЬ ВТДанныеОПравеНаПенсию
	|ИЗ
	|	(ВЫБРАТЬ
	|		Периоды.Период КАК Период,
	|		ГражданствоФизЛиц.ФизЛицо КАК Физлицо,
	|		МАКСИМУМ(ГражданствоФизЛиц.Период) КАК ПериодРегистра
	|	ИЗ
	|		ВТПериоды КАК Периоды
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГражданствоФизЛиц КАК ГражданствоФизЛиц
	|			ПО Периоды.Период >= ГражданствоФизЛиц.Период
	|				И (ГражданствоФизЛиц.ФизЛицо = &ФизЛицо)
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ГражданствоФизЛиц.ФизЛицо,
	|		Периоды.Период) КАК Периоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГражданствоФизЛиц КАК ГражданствоФизЛиц
	|		ПО Периоды.ПериодРегистра = ГражданствоФизЛиц.Период
	|			И Периоды.Физлицо = ГражданствоФизЛиц.ФизЛицо
	|			И (ГражданствоФизЛиц.НеИмеетПравоНаПенсию)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";
	Запрос.Выполнить();
	
    // УчетнаяПолитика
	// Таблица УчетнаяПолитикаУСН - это список периодов, когда организация переходила на УСН
	// поля:
	//		УСН, 
	//		Месяц - месяц налогового периода
	// Описание:	
	//	Выбираем Из Периоды (таблица - список периодов с начала года по текущий период)
	//	Внутреннее соединение с "псевдосрезом" последних регистра УчетнаяПолитика
	//	по равенству периодов
	//  условие: что организация использует УСН
	
	Если РегламентированнаяОтчетность.ИДКонфигурации() = "БП" 
		ИЛИ РегламентированнаяОтчетность.ИДКонфигурации() = "БПКОРП"
		ИЛИ РегламентированнаяОтчетность.ИДКонфигурации() = "БАУ" Тогда
		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	МЕСЯЦ(Периоды.Период) КАК Месяц,
		|	ВЫБОР
		|		КОГДА УчетнаяПолитикаНалоговыйУчет.СистемаНалогообложения = ЗНАЧЕНИЕ(Перечисление.СистемыНалогообложения.Упрощенная)
		|			ТОГДА ИСТИНА
		|		ИНАЧЕ ЛОЖЬ
		|	КОНЕЦ КАК УСН
		|ПОМЕСТИТЬ ВТУчетнаяПолитикаНалоговыйУчет
		|ИЗ
		|	(ВЫБРАТЬ
		|		Периоды.Период КАК Период,
		|		МАКСИМУМ(УчетнаяПолитикаНалоговыйУчет.Период) КАК ПериодРегистра
		|	ИЗ
		|		ВТПериоды КАК Периоды
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.УчетнаяПолитикаОрганизаций КАК УчетнаяПолитикаНалоговыйУчет
		|			ПО Периоды.Период >= УчетнаяПолитикаНалоговыйУчет.Период
		|				И (УчетнаяПолитикаНалоговыйУчет.Организация = &ГоловнаяОрганизация)
		|	
		|	СГРУППИРОВАТЬ ПО
		|		Периоды.Период) КАК Периоды
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.УчетнаяПолитикаОрганизаций КАК УчетнаяПолитикаНалоговыйУчет
		|		ПО Периоды.ПериодРегистра = УчетнаяПолитикаНалоговыйУчет.Период
		|			И (УчетнаяПолитикаНалоговыйУчет.Организация = &ГоловнаяОрганизация)
		|			И (УчетнаяПолитикаНалоговыйУчет.СистемаНалогообложения = ЗНАЧЕНИЕ(Перечисление.СистемыНалогообложения.Упрощенная))
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Месяц";	
		Запрос.Выполнить();
		
	Иначе
		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	МЕСЯЦ(Периоды.Период) КАК Месяц,
		|	УчетнаяПолитикаНалоговыйУчет.УСН КАК УСН
		|ПОМЕСТИТЬ ВТУчетнаяПолитикаНалоговыйУчет
		|ИЗ
		|	(ВЫБРАТЬ
		|		Периоды.Период КАК Период,
		|		МАКСИМУМ(УчетнаяПолитикаНалоговыйУчет.Период) КАК ПериодРегистра
		|	ИЗ
		|		ВТПериоды КАК Периоды
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.УчетнаяПолитикаНалоговыйУчет КАК УчетнаяПолитикаНалоговыйУчет
		|			ПО Периоды.Период >= УчетнаяПолитикаНалоговыйУчет.Период
		|				И (УчетнаяПолитикаНалоговыйУчет.Организация = &ГоловнаяОрганизация)
		|	
		|	СГРУППИРОВАТЬ ПО
		|		Периоды.Период) КАК Периоды
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.УчетнаяПолитикаНалоговыйУчет КАК УчетнаяПолитикаНалоговыйУчет
		|		ПО Периоды.ПериодРегистра = УчетнаяПолитикаНалоговыйУчет.Период
		|			И (УчетнаяПолитикаНалоговыйУчет.Организация = &ГоловнаяОрганизация)
		|			И (УчетнаяПолитикаНалоговыйУчет.УСН)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Месяц";	
		Запрос.Выполнить();
		
	КонецЕсли;

	// ПоказателиДоходовПоМесяцам
	// Описание:
	//  Вычисляет показатели отчета, основанные на сведениях о доходах
					 
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Доходы.Месяц КАК Месяц,
	|	СУММА(ВЫБОР
	|			КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|					И Доходы.КодДоходаЕСН.ВходитВБазуФедеральныйБюджет
	|					И ФизлицаБезНалоговойБазы.ФизЛицо ЕСТЬ NULL 
	|				ТОГДА Доходы.Результат - Доходы.Скидка
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК НалоговаяБазаФБ,
	|	СУММА(ВЫБОР
	|			КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|					И Иностр.Физлицо ЕСТЬ NULL 
	|					И Доходы.КодДоходаЕСН.ВходитВБазуФедеральныйБюджет
	|					И ФизлицаБезНалоговойБазы.ФизЛицо ЕСТЬ NULL 
	|				ТОГДА Доходы.Результат - Доходы.Скидка
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК БазаПФР,
	|	СУММА(ВЫБОР
	|			КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|					И Доходы.КодДоходаЕСН.ВходитВБазуФСС
	|					И ФизлицаБезНалоговойБазы.ФизЛицо ЕСТЬ NULL 
	|				ТОГДА Доходы.Результат - Доходы.Скидка
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК НалоговаяБазаФСС,
	|	СУММА(ВЫБОР
	|			КОГДА Доходы.КодДоходаЕСН <> ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.НеЯвляетсяОбъектом)
	|				ТОГДА Доходы.Результат
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК НачисленоВсего,
	|	СУММА(ВЫБОР
	|			КОГДА Доходы.КодДоходаЕСН = ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.ВыплатыЗаСчетПрибыли)
	|				ТОГДА Доходы.Результат
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК ВыплатыЗаСчетПрибыли,
	|	СУММА(ВЫБОР
	|			КОГДА Доходы.КодДоходаЕСН В (ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.ПособияЗаСчетФСС), ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.НеОблагаетсяЦеликом))
	|				ТОГДА Доходы.Результат
	|			ИНАЧЕ Доходы.Скидка
	|		КОНЕЦ) КАК НеОблагаетсяПоСт238КромеДоговоров,
	|	СУММА(ВЫБОР
	|			КОГДА Доходы.КодДоходаЕСН В (ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.ДоговораГПХ), ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.ДоговораАвторские))
	|				ТОГДА Доходы.Результат
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК ВыплатыПоДоговорам,
	|	СУММА(ВЫБОР
	|			КОГДА Доходы.КодДоходаЕСН = ЗНАЧЕНИЕ(Справочник.ДоходыЕСН.ПособияЗаСчетФСС)
	|				ТОГДА Доходы.Результат
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК ПособияЗаСчетФСС
	|ПОМЕСТИТЬ ВТПоказателиДоходовПоМесяцам
	|ИЗ
	|	ВТДоходыПоМесяцамКодам КАК Доходы
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТФизлицаБезНалоговойБазы КАК ФизлицаБезНалоговойБазы
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТДанныеОПравеНаПенсию КАК Иностр
	|		ПО Доходы.Месяц = Иностр.Месяц
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТУчетнаяПолитикаНалоговыйУчет КАК УчетнаяПолитикаНалоговыйУчетУСН
	|		ПО Доходы.Месяц = УчетнаяПолитикаНалоговыйУчетУСН.Месяц
	|
	|СГРУППИРОВАТЬ ПО
	|	Доходы.Месяц
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";
	Запрос.Выполнить();
	
	// ПоказателиДоходовНарастающимИтогом
	// Описание:
	//  Вычисляет показатели отчета, основанные на сведениях о доходах - нарастающим итогом
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МесяцыНП.Месяц КАК Месяц,
	|	СУММА(ПоказателиДоходов.НалоговаяБазаФБ) КАК НалоговаяБазаФБ,
	|	СУММА(ПоказателиДоходов.БазаПФР) КАК БазаПФР,
	|	СУММА(ПоказателиДоходов.НалоговаяБазаФСС) КАК НалоговаяБазаФСС,
	|	СУММА(ПоказателиДоходов.НачисленоВсего) КАК НачисленоВсего,
	|	СУММА(ПоказателиДоходов.ВыплатыЗаСчетПрибыли) КАК ВыплатыЗаСчетПрибыли,
	|	СУММА(ПоказателиДоходов.НеОблагаетсяПоСт238КромеДоговоров) КАК НеОблагаетсяПоСт238КромеДоговоров,
	|	СУММА(ПоказателиДоходов.ВыплатыПоДоговорам) КАК ВыплатыПоДоговорам,
	|	СУММА(ПоказателиДоходов.ПособияЗаСчетФСС) КАК ПособияЗаСчетФСС
	|ПОМЕСТИТЬ ВТПоказателиДоходовНарастающимИтогом
	|ИЗ
	|	ВТМесяцыНП КАК МесяцыНП
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиДоходовПоМесяцам КАК ПоказателиДоходов
	|		ПО МесяцыНП.Месяц >= ПоказателиДоходов.Месяц
	|
	|СГРУППИРОВАТЬ ПО
	|	МесяцыНП.Месяц
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";
	Запрос.Выполнить();

	
	// ПоказателиНалогПоМесяцам
	// Описание:
	//	Вычисляет показатели отчета, основанные на сведениях о налогах.
	//  Из по ЕСН автоматически отнимается налог, приходящийся  на налоговую льготу инвалидов.
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	МЕСЯЦ(ЕСНИсчисленный.Период) КАК Месяц,
	|	ЕСНИсчисленный.ФедеральныйБюджетОборот КАК ИсчисленоФБ,
	|	ЕСНИсчисленный.ФССОборот КАК ИсчисленоФСС,
	|	ЕСНИсчисленный.ФФОМСОборот КАК ИсчисленоФФОМС,
	|	ЕСНИсчисленный.ТФОМСОборот КАК ИсчисленоТФОМС,
	|	ЕСНИсчисленный.ПримененнаяЛьготаФБОборот * (Ставки.ФедеральныйБюджетВПроцентах - Ставки.ПФРНакопительная1вПроцентах - Ставки.ПФРСтраховая1вПроцентах) / 100 КАК НеПодлежитФБ,
	|	ЕСНИсчисленный.ПримененнаяЛьготаФССОборот * Ставки.ФССвПроцентах / 100 КАК НеПодлежитФСС,
	|	ЕСНИсчисленный.ПримененнаяЛьготаФОМСОборот * Ставки.ФФОМСвПроцентах / 100 КАК НеПодлежитФФОМС,
	|	ЕСНИсчисленный.ПримененнаяЛьготаФОМСОборот * Ставки.ТФОМСвПроцентах / 100 КАК НеПодлежитТФОМС,
	|	ЕСНИсчисленный.ФедеральныйБюджетОборот - ЕСНИсчисленный.ПримененнаяЛьготаФБОборот * (Ставки.ФедеральныйБюджетВПроцентах - Ставки.ПФРНакопительная1вПроцентах - Ставки.ПФРСтраховая1вПроцентах) / 100 - ВЫБОР
	|		КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|			ТОГДА ЕСНИсчисленный.ПФРСтраховаяОборот - ЕСНИсчисленный.ПФРСтраховаяЕНВДОборот + ЕСНИсчисленный.ПФРНакопительнаяОборот - ЕСНИсчисленный.ПФРНакопительнаяЕНВДОборот
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК НачисленоФБ,
	|	ЕСНИсчисленный.ФССОборот - ЕСНИсчисленный.ПримененнаяЛьготаФССОборот * Ставки.ФССвПроцентах / 100 КАК НачисленоФСС,
	|	ЕСНИсчисленный.ФФОМСОборот - ЕСНИсчисленный.ПримененнаяЛьготаФОМСОборот * Ставки.ФФОМСвПроцентах / 100 КАК НачисленоФФОМС,
	|	ЕСНИсчисленный.ТФОМСОборот - ЕСНИсчисленный.ПримененнаяЛьготаФОМСОборот * Ставки.ТФОМСвПроцентах / 100 КАК НачисленоТФОМС,
	|	ЕСНИсчисленный.ПримененнаяЛьготаФБОборот КАК ПримененнаяЛьготаИнвалида,
	|	ВЫБОР
	|		КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|			ТОГДА ЕСНИсчисленный.ПФРНакопительнаяОборот - ЕСНИсчисленный.ПФРНакопительнаяЕНВДОборот
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК НачисленоПФРНакопительная,
	|	ВЫБОР
	|		КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|			ТОГДА ЕСНИсчисленный.ПФРСтраховаяОборот - ЕСНИсчисленный.ПФРСтраховаяЕНВДОборот
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК НачисленоПФРСтраховая,
	|	ВЫБОР
	|		КОГДА УчетнаяПолитикаНалоговыйУчетУСН.УСН ЕСТЬ NULL 
	|			ТОГДА ЕСНИсчисленный.ПФРСтраховаяОборот - ЕСНИсчисленный.ПФРСтраховаяЕНВДОборот + ЕСНИсчисленный.ПФРНакопительнаяОборот - ЕСНИсчисленный.ПФРНакопительнаяЕНВДОборот
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК НачисленоПФР
	|ПОМЕСТИТЬ ВТПоказателиНалоговПоМесяцам
	|ИЗ
	|	РегистрНакопления.ЕСНИсчисленный.Обороты(
	|			&НачалоНП,
	|			&КонецНП,
	|			Месяц,
	|			Организация = &ГоловнаяОрганизация
	|				И ФизЛицо = &ФизЛицо) КАК ЕСНИсчисленный
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТУчетнаяПолитикаНалоговыйУчет КАК УчетнаяПолитикаНалоговыйУчетУСН
	|		ПО (УчетнаяПолитикаНалоговыйУчетУСН.Месяц = МЕСЯЦ(ЕСНИсчисленный.Период))
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОСтавкахЕСНиПФР КАК Ставки
	|		ПО ЕСНИсчисленный.Организация.ВидСтавокЕСНиПФР = Ставки.ВидСтавокЕСНиПФР
	|			И (Ставки.Год = &ГодНП)
	|			И (Ставки.НомерСтрокиСтавок = 1)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";
	Запрос.Выполнить();
	
	// ПоказателиНалоговНарастающимИтогом
	// Описание:
	//  Вычисляет показатели отчета, основанные на сведениях о налогах - нарастающим итогом
	
	ДанныеРасчетаТекст = 
	"ВЫБРАТЬ
	|	МесяцыНП.Месяц КАК Месяц,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.ИсчисленоФБ) КАК ЧИСЛО(15, 5)) КАК ИсчисленоФБ,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.ИсчисленоФСС) КАК ЧИСЛО(15, 5)) КАК ИсчисленоФСС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.ИсчисленоФФОМС) КАК ЧИСЛО(15, 5)) КАК ИсчисленоФФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.ИсчисленоТФОМС) КАК ЧИСЛО(15, 5)) КАК ИсчисленоТФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НеПодлежитФБ) КАК ЧИСЛО(15, 5)) КАК НеПодлежитФБ,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НеПодлежитФСС) КАК ЧИСЛО(15, 5)) КАК НеПодлежитФСС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НеПодлежитФФОМС) КАК ЧИСЛО(15, 5)) КАК НеПодлежитФФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НеПодлежитТФОМС) КАК ЧИСЛО(15, 5)) КАК НеПодлежитТФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоФБ) КАК ЧИСЛО(15, 5)) КАК НачисленоФБ,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоФСС) КАК ЧИСЛО(15, 5)) КАК НачисленоФСС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоФФОМС) КАК ЧИСЛО(15, 5)) КАК НачисленоФФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоТФОМС) КАК ЧИСЛО(15, 5)) КАК НачисленоТФОМС,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.ПримененнаяЛьготаИнвалида) КАК ЧИСЛО(15, 5)) КАК ПримененнаяЛьготаИнвалида,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоПФРНакопительная) КАК ЧИСЛО(15, 5)) КАК НачисленоПФРНакопительная,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоПФРСтраховая) КАК ЧИСЛО(15, 5)) КАК НачисленоПФРСтраховая,
	|	ВЫРАЗИТЬ(СУММА(ПоказателиНалогов.НачисленоПФР) КАК ЧИСЛО(15, 5)) КАК НачисленоПФР
	|ПОМЕСТИТЬ ВТПоказателиНалоговНарастающимИтогом
	|ИЗ
	|	ВТМесяцыНП КАК МесяцыНП
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиНалоговПоМесяцам КАК ПоказателиНалогов
	|		ПО МесяцыНП.Месяц >= ПоказателиНалогов.Месяц
	|
	|СГРУППИРОВАТЬ ПО
	|	МесяцыНП.Месяц
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Месяц";	
									
	Запрос.Текст = ДанныеРасчетаТекст;
	Запрос.Выполнить();
	
	//ДанныеРасчетаТекст
	// Описание: объединяет показатели доходов и налогов
	
	ДанныеРасчетаТекст = 
	"ВЫБРАТЬ
	|	МесяцыНП.Месяц КАК Месяц,
	|	ПоказателиДоходов.НалоговаяБазаФБ,
	|	ПоказателиДоходовНарастающимИтогом.НалоговаяБазаФБ КАК НарастНалоговаяБазаФБ,
	|	ПоказателиДоходов.БазаПФР,
	|	ПоказателиДоходовНарастающимИтогом.БазаПФР КАК НарастБазаПФР,
	|	ПоказателиДоходов.НалоговаяБазаФСС,
	|	ПоказателиДоходовНарастающимИтогом.НалоговаяБазаФСС КАК НарастНалоговаяБазаФСС,
	|	ПоказателиДоходов.НачисленоВсего,
	|	ПоказателиДоходовНарастающимИтогом.НачисленоВсего КАК НарастНачисленоВсего,
	|	ПоказателиДоходов.ВыплатыЗаСчетПрибыли,
	|	ПоказателиДоходовНарастающимИтогом.ВыплатыЗаСчетПрибыли КАК НарастВыплатыЗаСчетПрибыли,
	|	ПоказателиДоходов.НеОблагаетсяПоСт238КромеДоговоров,
	|	ПоказателиДоходовНарастающимИтогом.НеОблагаетсяПоСт238КромеДоговоров КАК НарастНеОблагаетсяПоСт238КромеДоговоров,
	|	ПоказателиДоходов.ВыплатыПоДоговорам,
	|	ПоказателиДоходовНарастающимИтогом.ВыплатыПоДоговорам КАК НарастВыплатыПоДоговорам,
	|	ПоказателиДоходов.ПособияЗаСчетФСС,
	|	ПоказателиДоходовНарастающимИтогом.ПособияЗаСчетФСС КАК НарастПособияЗаСчетФСС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФБ - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.ИсчисленоФБ, 0) КАК ИсчисленоФБ,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФБ КАК НарастИсчисленоФБ,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФСС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.ИсчисленоФСС, 0) КАК ИсчисленоФСС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФСС КАК НарастИсчисленоФСС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.ИсчисленоФФОМС, 0) КАК ИсчисленоФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоФФОМС КАК НарастИсчисленоФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоТФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.ИсчисленоТФОМС, 0) КАК ИсчисленоТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.ИсчисленоТФОМС КАК НарастИсчисленоТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФБ - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НеПодлежитФБ, 0) КАК НеПодлежитФБ,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФБ КАК НарастНеПодлежитФБ,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФСС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НеПодлежитФСС, 0) КАК НеПодлежитФСС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФСС КАК НарастНеПодлежитФСС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НеПодлежитФФОМС, 0) КАК НеПодлежитФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитФФОМС КАК НарастНеПодлежитФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитТФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НеПодлежитТФОМС, 0) КАК НеПодлежитТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НеПодлежитТФОМС КАК НарастНеПодлежитТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФБ - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоФБ, 0) КАК НачисленоФБ,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФБ КАК НарастНачисленоФБ,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФСС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоФСС, 0) КАК НачисленоФСС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФСС КАК НарастНачисленоФСС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоФФОМС, 0) КАК НачисленоФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоФФОМС КАК НарастНачисленоФФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоТФОМС - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоТФОМС, 0) КАК НачисленоТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоТФОМС КАК НарастНачисленоТФОМС,
	|	ПоказателиНалоговНарастающимИтогом.ПримененнаяЛьготаИнвалида - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.ПримененнаяЛьготаИнвалида, 0) КАК ПримененнаяЛьготаИнвалида,
	|	ПоказателиНалоговНарастающимИтогом.ПримененнаяЛьготаИнвалида КАК НарастПримененнаяЛьготаИнвалида,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФРНакопительная - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоПФРНакопительная, 0) КАК НачисленоПФРНакопительная,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФРНакопительная КАК НарастНачисленоПФРНакопительная,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФРСтраховая - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоПФРСтраховая, 0) КАК НачисленоПФРСтраховая,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФРСтраховая КАК НарастНачисленоПФРСтраховая,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФР - ЕСТЬNULL(ПоказателиНалоговПоПрошлыйМесяц.НачисленоПФР, 0) КАК НачисленоПФР,
	|	ПоказателиНалоговНарастающимИтогом.НачисленоПФР КАК НарастНачисленоПФР
	|ИЗ
	|	ВТМесяцыНП КАК МесяцыНП
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиДоходовПоМесяцам КАК ПоказателиДоходов
	|		ПО МесяцыНП.Месяц = ПоказателиДоходов.Месяц
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиНалоговПоМесяцам КАК ПоказателиНалогов
	|		ПО МесяцыНП.Месяц = ПоказателиНалогов.Месяц
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиДоходовНарастающимИтогом КАК ПоказателиДоходовНарастающимИтогом
	|		ПО МесяцыНП.Месяц = ПоказателиДоходовНарастающимИтогом.Месяц
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиНалоговНарастающимИтогом КАК ПоказателиНалоговНарастающимИтогом
	|		ПО МесяцыНП.Месяц = ПоказателиНалоговНарастающимИтогом.Месяц
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТПоказателиНалоговНарастающимИтогом КАК ПоказателиНалоговПоПрошлыйМесяц
	|		ПО (МесяцыНП.Месяц - 1 = ПоказателиНалоговПоПрошлыйМесяц.Месяц)
	|ГДЕ
	|	(ПоказателиДоходов.Месяц ЕСТЬ НЕ NULL 
	|			ИЛИ ПоказателиНалогов.Месяц ЕСТЬ НЕ NULL )
	|
	|УПОРЯДОЧИТЬ ПО
	|	Месяц";					   
						   
	
	//-----------------------------------------------------------------------------
	// ВЫПОЛНЕНИЕ ЗАПРОСОВ
	
	// Сведения о физлице
	Запрос.Текст = ДанныеОФизлицеТекст;
	ДанныеОФизЛице  = Запрос.Выполнить().Выбрать();
	ДанныеОФизЛице.Следующий();
	
	// Данные расчета
	Запрос.Текст = ДанныеРасчетаТекст;
	ДанныеРасчета  = Запрос.Выполнить().Выбрать();
	
	
	//-----------------------------------------------------------------------------
	// ЗАПОЛНЕНИЕ ФОРМЫ
	
	// Области макета
    ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьМесяц = Макет.ПолучитьОбласть("Месяц");
	ОбластьПустойМесяц = Макет.ПолучитьОбласть("ПустойМесяц");
	
	// настроим формат вывода данных о налогах
	ФорматВыводаЕСН = "ЧДЦ=5; ЧРД=.";
	ФорматВыводаПФР = "ЧДЦ=5; ЧРД=.";
	
	ОбластиСтроки = ОбластьМесяц.Области;
	Для НомерКолонки = 13 По 16 Цикл
		ОбластиСтроки["П" + НомерКолонки].Формат = ФорматВыводаЕСН;
		ОбластиСтроки["СНГ" + НомерКолонки].Формат = ФорматВыводаЕСН;
	КонецЦикла;
	Для НомерКолонки = 20 По 22 Цикл
		ОбластиСтроки["П" + НомерКолонки].Формат = ФорматВыводаПФР;
		ОбластиСтроки["СНГ" + НомерКолонки].Формат = ФорматВыводаПФР;
	КонецЦикла;
	Для НомерКолонки = 24 По 31 Цикл
		ОбластиСтроки["П" + НомерКолонки].Формат = ФорматВыводаЕСН;
		ОбластиСтроки["СНГ" + НомерКолонки].Формат = ФорматВыводаЕСН;
	КонецЦикла;
	
	// Вывод шапки отчета
	ОбластьШапка.Параметры.Заполнить(ДанныеОФизЛице);
	ОбластьШапка.Параметры.ДокументКемКогдаВыдан = СОКРЛП(ДанныеОФизЛице.ДокументКемКогдаВыдан);
	ОбластьШапка.Параметры.НалоговыйПериод = Формат(НалоговыйПериод,"ЧГ=");
	ОбластьШапка.Параметры.ДатаРождения = Формат(ДанныеОФизЛице.ДатаРождения,"ЧГ=; ДФ=dd.MM.yyyy");
	ОбластьШапка.Параметры.ДокументДатаВыдачи = Формат(ДанныеОФизЛице.ДокументДатаВыдачи,"ДФ=dd.MM.yyyy");
	Если СтрЗаменить(ДанныеОФизЛице.АдресФактический, ",","") = "" Тогда
		ОбластьШапка.Параметры.Адрес = РегламентированнаяОтчетность.ПредставлениеАдреса(ДанныеОФизЛице.АдресРегистрации);
	Иначе	
		ОбластьШапка.Параметры.Адрес = РегламентированнаяОтчетность.ПредставлениеАдреса(ДанныеОФизЛице.АдресФактический);	
	КонецЕсли; 
	Если ДанныеОФизЛице.ТрудовойДоговор Тогда
		ОбластьТекст = ОбластьШапка.Область("R7C10");
		ОбластьТекст.Шрифт = Новый Шрифт(ОбластьТекст.Шрифт,,,,,Истина);
	КонецЕсли;
	ДокументРезультат.Вывести(ОбластьШапка);
	
	// Вывод сведений о доходах и налогах по месяцам налогового периода
	
	// вычислим последний месяц, за который есть сведения
	Месяц = 0;
	
	Пока ДанныеРасчета.Следующий() Цикл
		Месяц = ДанныеРасчета.Месяц;
		
		ОбластьМесяц.Параметры.Заполнить(ДанныеРасчета);
		ОбластьМесяц.Параметры.Месяц = Формат(Дата(НалоговыйПериод,Месяц,1),"ДФ=ММММ");
		
		// проставим в расшифровки название области, для того чтоб потом понять что нам надо расшифровывать 
		Для Каждого Область Из ОбластьМесяц.Области Цикл
			Если Область.Имя = "Месяц" Или Найти(Область.Имя, "R") > 0 Тогда 
				Продолжить
			Иначе
				ОбластьМесяц.Области[Область.Имя].Расшифровка = Новый Структура("Имя,Месяц",Область.Имя,Месяц);
			КонецЕсли;
		КонецЦикла;					
		
		// Выведем месяц
		ДокументРезультат.Вывести(ОбластьМесяц);
		
	КонецЦикла; 
	
	Если Месяц < 12 Тогда  // дополним таблицу пустыми строками
		Для СчМесяцев = Месяц + 1 По 12 Цикл
			// Выведем пустой месяц
			ОбластьПустойМесяц.Параметры.Месяц = Формат(Дата(НалоговыйПериод,СчМесяцев,1),"ДФ=ММММ");
			ДокументРезультат.Вывести(ОбластьПустойМесяц);
		КонецЦикла;		
	КонецЕсли; 
	
	//-----------------------------------------------------------------------------

	//Параметры документа
	ДокументРезультат.Автомасштаб 			= 	Истина;
	ДокументРезультат.ОриентацияСтраницы 	= 	ОриентацияСтраницы.Ландшафт;
	ДокументРезультат.ТолькоПросмотр		= 	Истина;
	
КонецПроцедуры


#КонецЕсли

