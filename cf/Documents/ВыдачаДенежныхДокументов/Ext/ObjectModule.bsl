﻿Перем мВалютаРегламентированногоУчета Экспорт;
Перем мУчетнаяПолитика Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой расходного ордера на выдачу денежных документов
//
// Возвращаемое значение:
//  Табличный документ - печатная форма расходного ордера
//
Функция ПечатьВыдачаДенежныхДокументов()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Номер,
	|	Док.Дата,
	|	Док.Выдано КАК ПредставлениеПолучателя,
	|	Док.Организация,
	// {ОбособленныеПодразделения
	|	ВЫРАЗИТЬ(Док.ПодразделениеОрганизации.НаименованиеПолное КАК СТРОКА(200)) КАК ПредставлениеПодразделения,
	// }ОбособленныеПодразделения 
	|	Док.СуммаДокумента,
	|	Док.ВалютаДокумента
	|ИЗ
	|	Документ.ВыдачаДенежныхДокументов КАК Док
	|ГДЕ
	|	Док.Ссылка = &ТекущийДокумент";
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	ЗапросПоДенежнымДокументам = Новый Запрос();
	ЗапросПоДенежнымДокументам.УстановитьПараметр("ТекущийДокумент", Ссылка);
	ЗапросПоДенежнымДокументам.Текст =
	"ВЫБРАТЬ
	|	ДенежныеДокументы.НомерСтроки КАК НомерСтроки,
	|	ДенежныеДокументы.ДенежныйДокумент КАК ДенежныйДокумент,
	|	ПРЕДСТАВЛЕНИЕ(ДенежныеДокументы.ДенежныйДокумент) КАК ДенежныйДокументПредставление,
	|	ДенежныеДокументы.Количество КАК Количество,
	|	ДенежныеДокументы.Стоимость,
	|	ВЫБОР
	|		КОГДА ДенежныеДокументы.Ссылка.ВидОперации = ЗНАЧЕНИЕ(Перечисление.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику)
	|			ТОГДА ДенежныеДокументы.Сумма
	|		ИНАЧЕ ДенежныеДокументы.Стоимость
	|	КОНЕЦ КАК Сумма
	|ИЗ
	|	Документ.ВыдачаДенежныхДокументов.ДенежныеДокументы КАК ДенежныеДокументы
	|ГДЕ
	|	ДенежныеДокументы.Ссылка = &ТекущийДокумент";
	ТаблицаДенежныхДокументов = ЗапросПоДенежнымДокументам.Выполнить().Выгрузить();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ВыдачаДенежныхДокументов_РасходныйОрдер";
	Макет       = ПолучитьМакет("РасходныйОрдер");

	// Выводим шапку 

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, "Расходный ордер");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Организация");
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата);
	ОбластьМакета.Параметры.ПредставлениеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(
		СведенияОбОрганизации, "НаименованиеДляПечатныхФорм,");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подразделение");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьМакета = Макет.ПолучитьОбласть("КомуВыдано");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести табличную часть
	Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда
		ИмяОперации = "Возврат";
	Иначе
		ИмяОперации = "";
	КонецЕсли;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы" + ИмяОперации);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка" + ИмяОперации);
	Для Каждого СтрокаДенежногоДокумента Из ТаблицаДенежныхДокументов Цикл

		ОбластьМакета.Параметры.Заполнить(СтрокаДенежногоДокумента);
		ТабДокумент.Вывести(ОбластьМакета);

	КонецЦикла;

	// Вывести Итого
	ОбластьМакета = Макет.ПолучитьОбласть("Итого" + ИмяОперации);
	ОбластьМакета.Параметры.Сумма     = ОбщегоНазначения.ФорматСумм(ТаблицаДенежныхДокументов.Итог("Сумма"));
	Если ИмяОперации = "Возврат" Тогда
		ОбластьМакета.Параметры.Стоимость = ОбщегоНазначения.ФорматСумм(ТаблицаДенежныхДокументов.Итог("Стоимость"));
	КонецЕсли;
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести Сумму прописью
	ОбластьМакета = Макет.ПолучитьОбласть("СуммаПрописью");
	ОбластьМакета.Параметры.ИтоговаяСтрока = "Всего наименований " + ТаблицаДенежныхДокументов.Количество()
		+ ?(ИмяОперации = "Возврат", 
			" стоимостью " + ОбщегоНазначения.ФорматСумм(ТаблицаДенежныхДокументов.Итог("Стоимость"), Шапка.ВалютаДокумента), 
			"")
		+ ", на сумму " + ОбщегоНазначения.ФорматСумм(ТаблицаДенежныхДокументов.Итог("Сумма"), Шапка.ВалютаДокумента);
	ОбластьМакета.Параметры.СуммаПрописью = 
		ОбщегоНазначения.СформироватьСуммуПрописью(ТаблицаДенежныхДокументов.Итог("Сумма"), Шапка.ВалютаДокумента);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести подписи
	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // ПечатьВыдачаДенежныхДокументов()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	Если ИмяМакета = "РасходныйОрдер" тогда
		
		ТабДокумент = ПечатьВыдачаДенежныхДокументов();
		
	КонецЕсли;
	
	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект, Строка(ВидОперации)), НепосредственнаяПечать);
	
КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	СтруктураПечатныхФорм = Новый Структура;
	СтруктураПечатныхФорм.Вставить("РасходныйОрдер", "Расходный ордер");
	Возврат СтруктураПечатныхФорм;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

//////////////////////////////////////////////////////////////////////////////////
//// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары",
//  СтруктураШапкиДокумента   - структура, содержащая реквизиты шапки документа и результаты запроса по шапке
//
// Возвращаемое значение:
//  Сформированная таблица значений.
//
// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - структура, содержащая реквизиты шапки документа и результаты запроса по шапке,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	СтруктураОбязательныхПолей = Новый Структура("ВидОперации, Организация, СчетУчетаДенежныхДокументов");

	Если СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда

		СтруктураОбязательныхПолей.Вставить("Контрагент");
		СтруктураОбязательныхПолей.Вставить("ДоговорКонтрагента");
		СтруктураОбязательныхПолей.Вставить("СчетУчетаРасчетовСКонтрагентом");
		
		ЕстьРазницы = Ложь;
		Для каждого СтрокаДенежногоДокумента Из ДенежныеДокументы Цикл
			Если СтрокаДенежногоДокумента.Стоимость <> СтрокаДенежногоДокумента.Сумма Тогда
				ЕстьРазницы = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ЕстьРазницы Тогда
			СтруктураОбязательныхПолей.Вставить("СтатьяДоходовИРасходов");
			СтруктураОбязательныхПолей.Вставить("СчетУчетаДоходов");
			СтруктураОбязательныхПолей.Вставить("СчетУчетаРасходов");
		КонецЕсли;
		
	ИначеЕсли СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВыдачаПодотчетномуЛицу Тогда

		СтруктураОбязательныхПолей.Вставить("Контрагент", "Не указано подотчетное лицо");
		
	ИначеЕсли СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ПрочаяВыдача Тогда

		СтруктураОбязательныхПолей.Вставить("СчетУчетаРасчетовСКонтрагентом", "Не указан счет дебета");
		
	КонецЕсли;

	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

Процедура ПроверитьЗаполнениеТабличнойЧастиДенежныеДокументы(ТаблицаПоДенежнымДокументам, СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("ДенежныйДокумент, Количество");
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ДенежныеДокументы", СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры 

Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоДенежнымДокументам,Отказ, Заголовок);

	Проводки = Движения.Хозрасчетный;
	
	// Проводки по зачету авансов
	
	Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда
		
		// По договорам вида "Прочее" зачет авансов происходит только в режиме "Автоматически"
		СтруктураШапкиДокумента.Вставить("СпособЗачетаАвансов", Перечисления.СпособыЗачетаАвансов.Автоматически);
		СтруктураШапкиДокумента.Вставить("СчетУчетаРасчетовПоАвансам", СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом);
		ТаблицаЗачетаАвансов = Новый ТаблицаЗначений;
		
		ТаблицыДокумента = Новый Структура();
		ТаблицыДокумента.Вставить("ТаблицаПоДенежнымДокументам", ТаблицаПоДенежнымДокументам);

		ТаблицаВзаиморасчетов = УправлениеВзаиморасчетами.ЗачестьАвансКонтрагента(
			СтруктураШапкиДокумента, ТаблицыДокумента, ТаблицаЗачетаАвансов, Проводки, Истина, Отказ, Заголовок);

	Иначе
		
		ТаблицаВзаиморасчетов = Неопределено;
		
	КонецЕсли;
	
	// Проводки по выдаче денежных документов

	ДатаДока   = СтруктураШапкиДокумента.Дата;
	
	СодержаниеПроводок = "Выдача денежных документов";
	
	Для каждого СтрокаТаблицы Из ТаблицаПоДенежнымДокументам Цикл

		Проводка = Проводки.Добавить();

		Проводка.Период      = Дата;
		Проводка.Организация = СтруктураШапкиДокумента.Организация;
		Проводка.Содержание  = СодержаниеПроводок;

		Проводка.СчетКт      = СтруктураШапкиДокумента.СчетУчетаДенежныхДокументов;
		БухгалтерскийУчет.УстановитьСубконто(
			Проводка.СчетКт, Проводка.СубконтоКт, "ДенежныеДокументы", СтрокаТаблицы.ДенежныйДокумент, Истина);

		Если Проводка.СчетКт.Количественный Тогда
			Проводка.КоличествоКт = СтрокаТаблицы.Количество;
		КонецЕсли;

		Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда
			
			Проводка.Сумма = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(
				СтрокаТаблицы.Стоимость,
				СтруктураШапкиДокумента.ВалютаДокумента, мВалютаРегламентированногоУчета,
				СтруктураШапкиДокумента.КурсВзаиморасчетов, 1,
				СтруктураШапкиДокумента.КратностьВзаиморасчетов, 1);
			
			Проводка.СчетДт = СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом;
			БухгалтерскийУчет.УстановитьСубконто(
				Проводка.СчетДт, Проводка.СубконтоДт, "Контрагенты", СтруктураШапкиДокумента.Контрагент, Истина);
			БухгалтерскийУчет.УстановитьСубконто(
				Проводка.СчетДт, Проводка.СубконтоДт, "Договоры", СтруктураШапкиДокумента.ДоговорКонтрагента);
			БухгалтерскийУчет.УстановитьСубконто(
				Проводка.СчетДт, Проводка.СубконтоДт, "ДокументыРасчетовСКонтрагентами", Ссылка);
			
			Если Проводка.СчетДт.Валютный Тогда
				Проводка.ВалютаДт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаДт = СтрокаТаблицы.Стоимость;
			КонецЕсли;
			
			Если Проводка.СчетКт.Валютный Тогда
				Проводка.ВалютаКт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаКт = СтрокаТаблицы.Стоимость;
			КонецЕсли;
		
		ИначеЕсли ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВыдачаПодотчетномуЛицу Тогда

			Проводка.Сумма       = СтрокаТаблицы.СуммаБУ;
			
			Если Проводка.СчетКт.Валютный Тогда
				Проводка.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицамиВал;
			Иначе
				Проводка.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицами;
			КонецЕсли;
			БухгалтерскийУчет.УстановитьСубконто(
				Проводка.СчетДт, Проводка.СубконтоДт, "РаботникиОрганизаций", СтруктураШапкиДокумента.Контрагент, Истина);
			
			Если Проводка.СчетДт.Валютный Тогда
				Проводка.ВалютаДт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаДт = СтрокаТаблицы.СуммаВал;
			КонецЕсли;
			
			Если Проводка.СчетКт.Валютный Тогда
				Проводка.ВалютаКт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаКт = СтрокаТаблицы.СуммаВал;
			КонецЕсли;
			
		Иначе
			
			Проводка.Сумма       = СтрокаТаблицы.СуммаБУ;
			
			Проводка.СчетДт = СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом;
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, СубконтоДт1);
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2, СубконтоДт2);
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 3, СубконтоДт3);
			
			Если Проводка.СчетДт.Валютный Тогда
				Проводка.ВалютаДт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаДт = СтрокаТаблицы.СуммаВал;
			КонецЕсли;
			
			Если Проводка.СчетКт.Валютный Тогда
				Проводка.ВалютаКт        = СтруктураШапкиДокумента.ВалютаДокумента;
				Проводка.ВалютнаяСуммаКт = СтрокаТаблицы.СуммаВал;
			КонецЕсли;
			
		КонецЕсли;
		
		// {ОбособленныеПодразделения
		БухгалтерскийУчет.УстановитьПодразделенияПроводки(
			Проводка, СтруктураШапкиДокумента.ПодразделениеОрганизации, СтруктураШапкиДокумента.ПодразделениеОрганизации);
		// }ОбособленныеПодразделения
		
		// Отклонение суммы возврата поставщику от учетной стоимости денежных документов
		
		Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику 
			И СтрокаТаблицы.Стоимость <> СтрокаТаблицы.СуммаВал Тогда
			
			Если ВалютаДокумента = мВалютаРегламентированногоУчета Тогда
				СуммаОтклонения = СтрокаТаблицы.Стоимость - СтрокаТаблицы.СуммаБУ;
			Иначе
				СуммаОтклоненияВал = СтрокаТаблицы.Стоимость - СтрокаТаблицы.СуммаВал;
				СтоимостьРуб = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(
					СтрокаТаблицы.Стоимость,
					СтруктураШапкиДокумента.ВалютаДокумента, мВалютаРегламентированногоУчета,
					СтруктураШапкиДокумента.КурсВзаиморасчетов, 1,
					СтруктураШапкиДокумента.КратностьВзаиморасчетов, 1);
				СуммаОтклонения    = СтоимостьРуб - СтрокаТаблицы.СуммаБУ;
			КонецЕсли;
			
			Проводка = Проводки.Добавить();

			Проводка.Период      = Дата;
			Проводка.Организация = СтруктураШапкиДокумента.Организация;
			Проводка.Содержание  = СодержаниеПроводок;
			
			Если СуммаОтклонения > 0 Тогда
				
				Проводка.Сумма = СуммаОтклонения;
			
				Проводка.СчетДт      = СтруктураШапкиДокумента.СчетУчетаРасходов;
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетДт, Проводка.СубконтоДт, "ПрочиеДоходыИРасходы", СтруктураШапкиДокумента.СтатьяДоходовИРасходов);

				Проводка.СчетКт = СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом;
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетКт, Проводка.СубконтоКт, "Контрагенты", СтруктураШапкиДокумента.Контрагент, Истина);
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетКт, Проводка.СубконтоКт, "Договоры", СтруктураШапкиДокумента.ДоговорКонтрагента);
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетКт, Проводка.СубконтоКт, "ДокументыРасчетовСКонтрагентами", Ссылка);
					
				Если Проводка.СчетКт.Валютный Тогда
					Проводка.ВалютаКт        = СтруктураШапкиДокумента.ВалютаДокумента;
					Проводка.ВалютнаяСуммаКт = СуммаОтклоненияВал;
				КонецЕсли;
				
			Иначе
			
				Проводка.Сумма = -СуммаОтклонения;
				
				Проводка.СчетКт      = СтруктураШапкиДокумента.СчетУчетаДоходов;
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетКт, Проводка.СубконтоКт, "ПрочиеДоходыИРасходы", СтруктураШапкиДокумента.СтатьяДоходовИРасходов);
				
				Проводка.СчетДт = СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом;
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетДт, Проводка.СубконтоДт, "Контрагенты", СтруктураШапкиДокумента.Контрагент, Истина);
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетДт, Проводка.СубконтоДт, "Договоры", СтруктураШапкиДокумента.ДоговорКонтрагента);
				БухгалтерскийУчет.УстановитьСубконто(
					Проводка.СчетДт, Проводка.СубконтоДт, "ДокументыРасчетовСКонтрагентами", Ссылка);
					
				Если Проводка.СчетДт.Валютный Тогда
					Проводка.ВалютаДт        = СтруктураШапкиДокумента.ВалютаДокумента;
					Проводка.ВалютнаяСуммаДт = -СуммаОтклоненияВал;
				КонецЕсли;
				
			КонецЕсли;

			// {ОбособленныеПодразделения
			БухгалтерскийУчет.УстановитьПодразделенияПроводки(
				Проводка, СтруктураШапкиДокумента.ПодразделениеОрганизации, СтруктураШапкиДокумента.ПодразделениеОрганизации);
			// }ОбособленныеПодразделения
		
		КонецЕсли;	

	КонецЦикла;
	
	//Учет курсовых разниц
	БухгалтерскийУчет.ПереоценитьВалютныеОстатки(СтруктураШапкиДокумента, Движения, Отказ, Заголовок);
	
	Если СтруктураШапкиДокумента.ОтражатьВНалоговомУчетеУСН  ИЛИ СтруктураШапкиДокумента.ОтражатьВНалоговомУчетеУСНДоходы Тогда
		НалоговыйУчетУСН.ДвиженияУСН(ЭтотОбъект, РежимПроведения);
	КонецЕсли;
	
	// {УчетДоходовИРасходовИП
	// Учет доходов и расходов предпринимателя
	Если СтруктураШапкиДокумента.ОтражатьВНалоговомУчетеПредпринимателя  И ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ПрочаяВыдача Тогда 
		УчетнаяПолитикаНУ = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(СтруктураШапкиДокумента.Дата, Отказ, СтруктураШапкиДокумента.Организация);
		
		ТаблицаПоПрочее = ТаблицаПоДенежнымДокументам.Скопировать();;
		ТаблицаПоПрочее.Колонки.Удалить("Сумма");
		ТаблицаПоПрочее.Колонки.Добавить("СуммаБезНДС", Новый ОписаниеТипов("Число"));
		ТаблицаПоПрочее.Колонки.Добавить("НДС", Новый ОписаниеТипов("Число"));
		ТаблицаПоПрочее.Колонки.Добавить("Цена", Новый ОписаниеТипов("Число"));
		ТаблицаПоПрочее.Колонки.Добавить("СчетЗатрат");
		ТаблицаПоПрочее.Колонки.Добавить("Субконто1");
		ТаблицаПоПрочее.Колонки.Добавить("Субконто2");
		ТаблицаПоПрочее.Колонки.Добавить("Субконто3");
		
		Для Каждого СтрокаПоПрочее ИЗ ТаблицаПоПрочее Цикл
			СтрокаПоПрочее.СуммаБезНДС = СтрокаПоПрочее.СуммаБУ;
			СтрокаПоПрочее.СчетЗатрат = СтруктураШапкиДокумента.СчетУчетаРасчетовСКонтрагентом;
			СтрокаПоПрочее.Субконто1 = СтруктураШапкиДокумента.СубконтоДт1;
			СтрокаПоПрочее.Субконто2 = СтруктураШапкиДокумента.СубконтоДт2;
			СтрокаПоПрочее.Субконто3 = СтруктураШапкиДокумента.СубконтоДт3;			
		КонецЦикла;
		
		СписокПлатежей = ТаблицаПоПрочее.Скопировать(,"НомерСтроки,СуммаБУ,СуммаБезНДС,НДС");
		СписокПлатежей.Колонки.Добавить("РеквизитыДокументаОплаты");
		СписокПлатежей.Колонки.Добавить("ДокументОплаты");
		Для Каждого ДокументОплаты Из СписокПлатежей Цикл
			ДокументОплаты.ДокументОплаты = ЭтотОбъект.Ссылка;
			ДокументОплаты.РеквизитыДокументаОплаты = 
			ДоходыИРасходыПредпринимателя.РеквизитыДокументаОплатыСтр(СтруктураШапкиДокумента.Номер, СтруктураШапкиДокумента.Дата);			
		КонецЦикла;
		
		ДоходыИРасходыПредпринимателя.ПоступлениеМПЗ(ЭтотОбъект, СтруктураШапкиДокумента, УчетнаяПолитикаНУ, 1, ТаблицаПоПрочее, "СчетЗатрат", "Ценность", "Субконто", "Субконто", СписокПлатежей);		
	КонецЕсли;
	// }УчетДоходовИРасходовИП
	
КонецПроцедуры // ДвиженияПоРегистрам()

// Процедура формирует структуру шапки документа и дополнительных полей.
//
Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ) Экспорт
	
	Перем ДеревоПолейЗапросаПоШапке;
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда
		
		// Заполним по шапке документа дерево параметров, нужных при проведении.
		ДеревоПолейЗапросаПоШапке = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
		ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "Организация"          , "ДоговорОрганизация");
		ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "ВидДоговора"          , "ВидДоговора");
		
		// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
		СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, );

	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоДенежнымДокументам) Экспорт
	
	// Получим необходимые данные по табличной части "Денежные документы".
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ДенежныйДокумент"	, "ДенежныйДокумент");
	СтруктураПолей.Вставить("Количество"  		, "Количество");
	Если ВидОперации = Перечисления.ВидыОперацийВыдачаДенежныхДокументов.ВозвратПоставщику Тогда
		СтруктураПолей.Вставить("Сумма"       	, "Сумма");
		СтруктураПолей.Вставить("Стоимость"    	, "Стоимость");
	Иначе
		СтруктураПолей.Вставить("Сумма"    	, "Стоимость");
	КонецЕсли;

	РезультатЗапроса = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(
		ЭтотОбъект, "ДенежныеДокументы", СтруктураПолей);
		
	ТаблицаПоДенежнымДокументам = РезультатЗапроса.Выгрузить();
	
	БухгалтерскийУчетРасчетовСКонтрагентами.ПодготовкаТаблицыЗначенийДляЦелейПриобретенияИРеализации(
		ТаблицаПоДенежнымДокументам, СтруктураШапкиДокумента, Истина, мВалютаРегламентированногоУчета);

КонецПроцедуры	
	
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	НалоговыйУчетУСН.ЗаполнитьНастройкуКУДиР(ЭтотОбъект);
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УчетнаяПолитикаНеЗадана = Ложь;
	мУчетнаяПолитика = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(Дата, УчетнаяПолитикаНеЗадана, Организация);
		
	// Посчитать суммы документа и записать ее в соответствующий реквизит шапки для показа в журналах
	//СуммаДокумента = УчетНДС.ПолучитьСуммуДокументаСНДС(ЭтотОбъект);
	СуммаДокумента = ДенежныеДокументы.Итог("Стоимость");

КонецПроцедуры // ПередЗаписью

// Процедура - обработчик события "ОбработкаПроведения".
//
Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	Перем СтруктураШапкиДокумента, ТаблицаПоДенежнымДокументам;
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
     
	// Проверка ручной корректировки
	Если ОбщегоНазначения.РучнаяКорректировкаОбработкаПроведения(РучнаяКорректировка,Отказ,Заголовок,ЭтотОбъект) Тогда
		Возврат
	КонецЕсли;

	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ);
	
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);

	ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоДенежнымДокументам);

	ПроверитьЗаполнениеТабличнойЧастиДенежныеДокументы(
		ТаблицаПоДенежнымДокументам, СтруктураШапкиДокумента, Отказ, Заголовок);

	УправлениеВзаиморасчетами.ПроверкаВозможностиПроведенияВ_БУ_НУ(
		СтруктураШапкиДокумента, СтруктураШапкиДокумента.ДоговорКонтрагента, Отказ, Заголовок);

	Если Не Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоДенежнымДокументам, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ОбработкаПроведения()

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, РучнаяКорректировка, Ложь);

	УчетНДС.УстановкаПроведенияУСчетаФактуры(Ссылка, "СчетФактураПолученный", Ложь);
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
