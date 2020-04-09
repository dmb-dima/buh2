﻿////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента,Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация");

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "ОС".
//
// Параметры:
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиОС(Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("ОсновноеСредство,СпециальныйКоэффициент");

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиОС()

// Выполняет движения по регистрам Регл
//
Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента,ТаблицаПоОС)

	НаборДвижений   = Движения.НачислениеАмортизацииОССпециальныйКоэффициентНалоговыйУчет;
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();

	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоОС, ТаблицаДвижений);
	ТаблицаДвижений.ЗаполнитьЗначения(СтруктураШапкиДокумента.Дата,"Период");
	ТаблицаДвижений.ЗаполнитьЗначения(Истина,"Активность");
	ТаблицаДвижений.ЗаполнитьЗначения(СтруктураШапкиДокумента.Организация,"Организация");

	НаборДвижений.Загрузить(ТаблицаДвижений);

КонецПроцедуры // ДвиженияПоРегистрамРегл

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента,ТаблицаПоОС);
	
	ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента,ТаблицаПоОС);
	
КонецПроцедуры // ДвиженияПоРегистрам

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ)


	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство",       "ОсновноеСредство");
	СтруктураПолей.Вставить("СпециальныйКоэффициент", "СпециальныйКоэффициент");

	РезультатЗапросаПоОС = ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей);
	ТаблицаПоОС          = РезультатЗапросаПоОС.Выгрузить();

	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	ПроверитьЗаполнениеТабличнойЧастиОС(Отказ, Заголовок);
	
	// Проверим, нет ли повторяющихся основных средств в таблице по ОС.
	УправлениеВнеоборотнымиАктивами.ПроверитьДублиОС(ТаблицаПоОС, Отказ, Заголовок);
	
	Если НЕ Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента,ТаблицаПоОС);
		
	КонецЕсли;

КонецПроцедуры

