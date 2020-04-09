﻿Перем ПрошлыйИзмененныйГоловнаяОрганизация;

// Обработчик события "ПередЗаписью" Объекта
//
Процедура ПередЗаписью(Отказ)
	
	// проверим заполнение реквизита ВидСтавокЕСНиПФР, если он не заполнен, или значение не равно ДляНеСельскохозяйственныхПроизводителей
	// заполним реквизит, проверку и заполнение делаем всегда
	Если Не ЭтоГруппа И (Не ЗначениеЗаполнено(ВидСтавокЕСНиПФР) ИЛИ ВидСтавокЕСНиПФР <> Перечисления.ВидыСтавокЕСНиПФР.ДляНеСельскохозяйственныхПроизводителей) Тогда
		ВидСтавокЕСНиПФР = Перечисления.ВидыСтавокЕСНиПФР.ДляНеСельскохозяйственныхПроизводителей;
	КонецЕсли;
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// проверка корректности задания реквизитов справочника
	Если ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо И НЕ ЗначениеЗаполнено(ИндивидуальныйПредприниматель) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Организации - индивидуальному предпринимателю не сопоставлено физ. лицо!", Отказ);
		Возврат;
	КонецЕсли;
	
	ИННОрг = ?(ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо, ИндивидуальныйПредприниматель.ИНН, ИНН);
	Если НЕ ПустаяСтрока(ИННОрг) И НЕ РегламентированнаяОтчетность.ИННСоответствуетТребованиям(ИННОрг, ЮрФизЛицо) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("ИНН организации задан неверно!", Отказ);
	КонецЕсли;
	Если ЮрФизЛицо <> Перечисления.ЮрФизЛицо.ФизЛицо И Ссылка.КПП <> КПП Тогда
		Если НЕ ПустаяСтрока(КПП) И СтрДлина(КПП) <> 9 Тогда
			ОбщегоНазначения.СообщитьОбОшибке("КПП организации задан неверно!", Отказ);
		КонецЕсли;
	КонецЕсли;
	Если Ссылка.ОГРН <> ОГРН Тогда
		Если НЕ ПустаяСтрока(ОГРН) Тогда
			ОшибкаОГРН = Ложь;
			Если ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
				Если СтрДлина(СокрЛП(ОГРН)) <> 15 Тогда
					ОбщегоНазначения.СообщитьОбОшибке("ОГРНИП указан неверно! ОГРНИП должен состоять из 15 цифр!", Отказ);
					ОшибкаОГРН = Истина;
				КонецЕсли;
				Если НЕ ОбщегоНазначения.ТолькоЦифрыВСтроке(ОГРН) Тогда
					ОбщегоНазначения.СообщитьОбОшибке("ОГРНИП указан неверно! ОГРНИП должен состоять только из цифр!", Отказ);
					ОшибкаОГРН = Истина;
				КонецЕсли;
				Если НЕ Отказ Тогда
					ОГРН14 = Число(Лев(Строка(ОГРН), 14));
					Если НЕ ОшибкаОГРН И Прав(Формат(ОГРН14 % 13, "ЧН=0; ЧГ=0"), 1) <> Прав(ОГРН, 1) Тогда
						ОбщегоНазначения.СообщитьОбОшибке("Возможно, ОГРНИП указан неверно (контрольный разряд не совпадает с вычисленным)!", , , СтатусСообщения.Внимание);
					КонецЕсли;
				КонецЕсли;
			Иначе
				Если СтрДлина(ОГРН) <> 13 Тогда
					ОбщегоНазначения.СообщитьОбОшибке("ОГРН организации указан неверно! ОГРН должен состоять из 13 цифр!", Отказ);
					ОшибкаОГРН = Истина;
				КонецЕсли;
				Если НЕ ОбщегоНазначения.ТолькоЦифрыВСтроке(ОГРН) Тогда
					ОбщегоНазначения.СообщитьОбОшибке("ОГРН организации указан неверно! ОГРН должен состоять только из цифр!", Отказ);
					ОшибкаОГРН = Истина;
				КонецЕсли;
				Если НЕ Отказ Тогда
					ОГРН12 = Число(Лев(Строка(ОГРН), 12));
					Если НЕ ОшибкаОГРН И Прав(Формат(ОГРН12 % 11, "ЧН=0; ЧГ=0"), 1) <> Прав(ОГРН, 1) Тогда
						ОбщегоНазначения.СообщитьОбОшибке("Возможно, ОГРН организации указан неверно (контрольный разряд не совпадает с вычисленным)!", , , СтатусСообщения.Внимание);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ЭтоНовый() И ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо И ЮрФизЛицо <> Ссылка.ЮрФизЛицо Тогда
		Запрос = Новый Запрос(
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	КОЛИЧЕСТВО(ИСТИНА) КАК КоличествоПодчиненных
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.ГоловнаяОрганизация = &ГоловнаяОрганизация");
		Запрос.УстановитьПараметр("ГоловнаяОрганизация", Ссылка);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Если ЗначениеЗаполнено(Выборка.КоличествоПодчиненных) Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Текущая организация является головной для других организаций из справочника.
					|Физическое лицо не может являться головной организацией!", Отказ);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ГоловнаяОрганизация) Тогда
		Запрос = Новый Запрос(
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ПРЕДСТАВЛЕНИЕ(Организации.ГоловнаяОрганизация) КАК ПредставлениеОрганизации
		|ИЗ
		|	Справочник.Организации КАК Организации
		|ГДЕ
		|	Организации.Ссылка = &ГоловнаяОрганизация
		|		И Организации.ГоловнаяОрганизация <> ЗНАЧЕНИЕ(Справочник.Организации.ПустаяСсылка)");
		Запрос.УстановитьПараметр("ГоловнаяОрганизация", ГоловнаяОрганизация);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Организация """ + ГоловнаяОрганизация + """ не может быть указана в реквизите ""Головная организация"",
				|	так как она является подразделением организации """ + Выборка.ПредставлениеОрганизации + """", Отказ);
		КонецЕсли;
	КонецЕсли;
	
	Если ВидОбменаСКонтролирующимиОрганами = Перечисления.ВидыОбменаСКонтролирующимиОрганами.ОбменВУниверсальномФормате Тогда
		Если УчетнаяЗаписьОбмена.Пустая() Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Не выбрана учетная запись обмена!", Отказ);
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ Отказ Тогда
		ПрошлыйИзмененныйГоловнаяОрганизация = ?(Не ЭтоНовый() и Не Ссылка.ГоловнаяОрганизация = ГоловнаяОрганизация, Ссылка.ГоловнаяОрганизация, Неопределено);
		НастройкаПравДоступа.ПередЗаписьюНовогоОбъектаСПравамиДоступаПользователей(ЭтотОбъект, Отказ, ГоловнаяОрганизация);
	КонецЕсли;
	
	// очистка неиспользуемых реквизитов
	Если НЕ Отказ Тогда
		Если ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо И ЗначениеЗаполнено(ИндивидуальныйПредприниматель) Тогда
			ИНН = ИндивидуальныйПредприниматель.ИНН;
		КонецЕсли;
		Если ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
			КПП								= "";
			КодОКОНХ						= "";
			ГоловнаяОрганизация 			= Неопределено;
		ИначеЕсли ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо Тогда
			ИндивидуальныйПредприниматель 	= Неопределено;
		КонецЕсли; 
		ИНН = СокрЛП(ИНН);
		ОГРН = СокрЛП(ОГРН);
		Если ВидОбменаСКонтролирующимиОрганами.Пустая() Тогда
			ВидОбменаСКонтролирующимиОрганами = Перечисления.ВидыОбменаСКонтролирующимиОрганами.ОбменОтключен;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Функция записывает новое значение ИНН для обособленных организаций.
//
// Параметры
//
// Возвращаемое значение:
//   Строка   – пустая строка, если записали ИНН,
//				текст об ошибке, если ИНН не удалось записать. 
//
Функция ОбновитьИННОбособленныхОрганизаций()

	Если ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо Тогда
		Возврат "";
	КонецЕсли;
	
	ТекстСообщения = "";
	ЗапросОрганизации = Новый Запрос;
	ЗапросОрганизации.УстановитьПараметр("ГоловнаяОрганизация", Ссылка);
	ЗапросОрганизации.УстановитьПараметр("ИНН", ИНН);
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Организации.Ссылка
	|ИЗ
	|	Справочник.Организации КАК Организации
	|
	|ГДЕ
	|	Организации.ГоловнаяОрганизация = &ГоловнаяОрганизация И
	|	Организации.ИНН <> &ИНН";
	
	ЗапросОрганизации.Текст = ТекстЗапроса;
	ВыборкаЗапроса = ЗапросОрганизации.Выполнить().Выбрать();
	Пока ВыборкаЗапроса.Следующий() Цикл
		ОбособленнаяОрганизация = ВыборкаЗапроса.Ссылка.ПолучитьОбъект();
		Попытка
		    ОбособленнаяОрганизация.Заблокировать();
		Исключение
			ТекстСообщения = "Организация: " + ВыборкаЗапроса.Ссылка + " - объект заблокирован.";
			Возврат ТекстСообщения;
		КонецПопытки;
	КонецЦикла;	    
	
	ВыборкаЗапроса.Сбросить(); 
	Пока ВыборкаЗапроса.Следующий() Цикл
		ОбособленнаяОрганизация = ВыборкаЗапроса.Ссылка.ПолучитьОбъект();
		ОбособленнаяОрганизация.ИНН = ИНН;
		ОбособленнаяОрганизация.Записать();
	КонецЦикла; 

	Возврат ТекстСообщения;

КонецФункции

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ТекстЗаписиИНН = ОбновитьИННОбособленныхОрганизаций();
	Если НЕ ПустаяСтрока(ТекстЗаписиИНН) Тогда
		ОбщегоНазначения.СообщитьОбОшибке(ТекстЗаписиИНН + Символы.ПС + "Элемент не записан!", Отказ);
		Возврат;
	КонецЕсли;
	
	НастройкаПравДоступа.ОбновитьПраваДоступаКИерархическимОбъектамПриНеобходимости(Ссылка,ПрошлыйИзмененныйГоловнаяОрганизация, Отказ);
	
КонецПроцедуры

