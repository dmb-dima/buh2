﻿Перем мВалютаРегламентированногоУчета Экспорт;
Перем мВалютаУправленческогоУчета     Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА
 
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
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	ОбязательныеРеквизитыШапки = "Организация, Склад";
	ДополнитьРеквизитыШапкиРегл(ОбязательныеРеквизитыШапки);
	
	СтруктураОбязательныхПолей = Новый Структура(ОбязательныеРеквизитыШапки);

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Процедура дополняет список реквизитов шапки регл. реквизитами
//
Процедура ДополнитьРеквизитыШапкиРегл(Реквизиты)
	
	Если Спецоснастка.Количество() > 0 Тогда
		Реквизиты = Реквизиты
		+ ?(ПустаяСтрока(Реквизиты), "", ", ")
		+ "ПодразделениеОрганизации";
	КонецЕсли;
			  
КонецПроцедуры // ДополнитьРеквизитыШапкиРегл()

// Процедура дополняет список реквизитов шапки регл. реквизитами
//
Процедура ДополнитьРеквизитыТабличнойЧастиРегл(СтруктураШапкиДокумента, Реквизиты)
	
	Реквизиты = Реквизиты 
	          + ?(ПустаяСтрока(Реквизиты), "", ", ") 
	          + "СчетУчета, СчетПередачи";
			  
КонецПроцедуры // ДополнитьРеквизитыТабличнойЧастиРегл()

// Процедура заполняет счета в строке табличной части документа.
//
Процедура ЗаполнитьСчетаУчетаВСтрокеТабЧасти(СтрокаТЧ) Экспорт

	СчетаУчета = БухгалтерскийУчет.ПолучитьСчетаУчетаНоменклатуры(Организация, СтрокаТЧ.Номенклатура, Склад);

	СтрокаТЧ.СчетУчета    = СчетаУчета.СчетУчета;
	СтрокаТЧ.СчетПередачи = СчетаУчета.СчетПередачи;
	
КонецПроцедуры // ЗаполнитьСчетаУчетаВСтрокеТабЧасти()

// Заполняет счета в табличной части документа.
//
Процедура ЗаполнитьСчетаУчетаВТабЧасти(ТабличнаяЧасть) Экспорт

	Для Каждого СтрокаТабЧасти Из ТабличнаяЧасть Цикл
		ЗаполнитьСчетаУчетаВСтрокеТабЧасти(СтрокаТабЧасти)
	КонецЦикла;

КонецПроцедуры // ЗаполнитьСчетаУчетаВТабЧасти()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Функция проверяет правильность заполнения документа
// Возврат - структура с данными шапки документа
//
Функция ПроверкаРеквизитов(Отказ) Экспорт
	
	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;
	
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Склад", "ВидСклада", "ВидСклада");
	
	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	РеквизитыТЧСпецодежда   = "Номенклатура, ПартияМатериаловВЭксплуатации, Количество, ФизЛицо";
	РеквизитыТЧСпецоснастка = "Номенклатура, ПартияМатериаловВЭксплуатации, Количество";
	
	ДополнитьРеквизитыТабличнойЧастиРегл(СтруктураШапкиДокумента, РеквизитыТЧСпецодежда);
	ДополнитьРеквизитыТабличнойЧастиРегл(СтруктураШапкиДокумента, РеквизитыТЧСпецоснастка);
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Спецодежда", Новый Структура(РеквизитыТЧСпецодежда), Отказ, Заголовок);
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Спецоснастка", Новый Структура(РеквизитыТЧСпецоснастка), Отказ, Заголовок);
	
	Возврат СтруктураШапкиДокумента;
	
КонецФункции // ПроверкаРеквизитов()

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры: 
//  РежимПроведения           - режим проведения документа (оперативный или неоперативный),
//  СтруктураШапкиДокумента   - выборка из результата запроса по шапке документа,
//  ТаблицаПоТоварам          - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  ТаблицаПоТаре             - таблица значений, содержащая данные для проведения и проверки ТЧ "Возвратная тара",
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериалам, Отказ, Заголовок)

	УСН = НалоговыйУчетУСН.ПрименениеУСН(Организация, Дата);
	
	ТаблицаПоМатериаламРегл = ТаблицаПоМатериалам.Скопировать();				
					
	ДвиженияПоРегистрамБухРегл(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериаламРегл, Отказ, Заголовок);
	
	ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, ТаблицаПоМатериаламРегл, Отказ, Заголовок);
	
	ДвиженияПоРегистрамУСНРегл(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериаламРегл, Отказ, Заголовок)
	
КонецПроцедуры // ДвиженияПоРегистрам()

// Формирование движений по регистрам по регламентированному учету.
//
Процедура ДвиженияПоРегистрамБухРегл(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериалам, Отказ, Заголовок)
	
	Проводки = Движения.Хозрасчетный;
	
	СкладПроводок = СтруктураШапкиДокумента.Склад;
	
	// Добавляем колонку Сумма для хранения списываемой суммы.
	Если ТаблицаПоМатериалам.Колонки.Найти("Сумма") = Неопределено Тогда
		ТаблицаПоМатериалам.Колонки.Добавить("Сумма");
	КонецЕсли;
	
	Если ТаблицаПоМатериалам.Колонки.Найти("СуммаПР") = Неопределено Тогда
		ТаблицаПоМатериалам.Колонки.Добавить("СуммаПР");
	КонецЕсли;
	
	Если ТаблицаПоМатериалам.Колонки.Найти("СуммаВР") = Неопределено Тогда
		ТаблицаПоМатериалам.Колонки.Добавить("СуммаВР");
	КонецЕсли;
	
	// Рассчитываем сумму погашения стоимости за текущий месяц.
	ТабАмортизации  = СпецодеждаИСпецоснастка.РасчетСуммыПогашенияСтоимостиМатериалов(ЭтотОбъект, СтруктураШапкиДокумента.Организация, ТаблицаПоМатериалам,,, Отказ);
		
	ТабАмортизации.Колонки.Номенклатура.Имя  = "ОбъектУчета";
	ТабЗатрат = СпецодеждаИСпецоснастка.ПолучитьРаспределениеПогашенияСтоимости(ЭтотОбъект, Отказ, Заголовок, ТабАмортизации, СтруктураШапкиДокумента);
	
	Для Каждого СтрокаТЧ Из ТаблицаПоМатериалам Цикл	
		
        МПЗ = БухгалтерскийУчет.ПолучитьНазваниеОбъекта(СтрокаТЧ.СчетПередачи);
		
		Если СтрокаТЧ.ТабличнаяЧасть = "Спецодежда" Тогда
			НадписьПодразделениеФизЛицо = "Работник";
		ИначеЕсли СтрокаТЧ.ТабличнаяЧасть = "Спецоснастка" Тогда
			НадписьПодразделениеФизЛицо = "Подразделение";
		КонецЕсли;
		
		// Проверяем, достаточный ли остаток материалов учтен на забалансовом счете
		Если СтрокаТЧ.Количество > СтрокаТЧ.КоличествоОстатокЗБ Тогда
		
			ОбщегоНазначения.СообщитьОбОшибке("Бух. учет. Строка: " + СтрокаТЧ.НомерСтроки + "
			                 |Не списано " + СтрокаТЧ.Количество + " " + СтрокаТЧ.Номенклатура.БазоваяЕдиницаИзмерения + 
							 " материала " + СтрокаТЧ.Номенклатура + " со счета " + СтрокаТЧ.СчетЗабалансовый + ".
			                 |", , , СтатусСообщения.Важное);
							 
			Отказ = Истина;
			
			Продолжить;
			
		КонецЕсли;
		
		// Рассчитываем сумму списания (забаланс.)
		ДоляСписанияЗБ = ?(СтрокаТЧ.КоличествоОстатокЗБ = 0, 0, СтрокаТЧ.Количество / СтрокаТЧ.КоличествоОстатокЗБ);
		
		СуммаСписанияЗБ   = СтрокаТЧ.СуммаОстатокЗБ * ДоляСписанияЗБ;
		СуммаСписанияПРЗБ = СтрокаТЧ.СуммаПРОстатокЗБ * ДоляСписанияЗБ;
		СуммаСписанияВРЗБ = СтрокаТЧ.СуммаВРОстатокЗБ * ДоляСписанияЗБ;
		
		// Проверяем, достаточный ли остаток по количеству (бух. учет)
		Если СтрокаТЧ.Количество > СтрокаТЧ.КоличествоОстаток Тогда
		
				ОбщегоНазначения.СообщитьОбОшибке("Бух. учет. Строка: " + СтрокаТЧ.НомерСтроки + "
				                 |Не списано " + СтрокаТЧ.Количество + " " + СтрокаТЧ.Номенклатура.БазоваяЕдиницаИзмерения + 
								 " материала " + СтрокаТЧ.Номенклатура + ", счет учета " + СтрокаТЧ.СчетПередачи + ".
				                 |", , , СтатусСообщения.Важное);
							 
			Отказ = Истина;
			
			Продолжить;
			
		КонецЕсли;
		
		// Рассчитываем сумму списания
		ДоляСписания = ?(СтрокаТЧ.КоличествоОстаток = 0, 0, СтрокаТЧ.Количество / СтрокаТЧ.КоличествоОстаток);
		
		СтрокаТЧ.Сумма   = СтрокаТЧ.СуммаОстаток * ДоляСписания - СтрокаТЧ.СуммаПогашения;
		СтрокаТЧ.СуммаПР = СтрокаТЧ.СуммаПРОстаток * ДоляСписания - СтрокаТЧ.СуммаПогашенияПР;
		СтрокаТЧ.СуммаВР = СтрокаТЧ.СуммаВРОстаток * ДоляСписания - СтрокаТЧ.СуммаПогашенияВР;
					   
		Проводка = Проводки.Добавить();

		Проводка.Период      = СтруктураШапкиДокумента.Дата;
		Проводка.Организация = СтруктураШапкиДокумента.Организация;
		Проводка.Содержание  = "Возврат " + МПЗ + " из эксплуатации";
		Проводка.Сумма       = СтрокаТЧ.Сумма;

		Проводка.СчетДт = СтрокаТЧ.СчетУчета;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "Номенклатура", СтрокаТЧ.Номенклатура);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "Склады",       СкладПроводок);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "Партии",       Ссылка);
		Проводка.КоличествоДт = СтрокаТЧ.Количество;
		Проводка.СуммаПРДт    = СтрокаТЧ.СуммаПР;
		Проводка.СуммаВРДт    = СтрокаТЧ.СуммаВР;

		Проводка.СчетКт = СтрокаТЧ.СчетПередачи;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "Номенклатура",                    СтрокаТЧ.Номенклатура);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ПартииМатериаловВЭксплуатации",   СтрокаТЧ.ПартияМатериаловВЭксплуатации);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 3,                                 СтрокаТЧ.ПодразделениеФизЛицо);
		Проводка.КоличествоКт = СтрокаТЧ.Количество;
		Проводка.СуммаПРКт    = СтрокаТЧ.СуммаПР;
		Проводка.СуммаВРКт    = СтрокаТЧ.СуммаВР;

		БухгалтерскийУчет.УстановитьПодразделенияПроводки(Проводка, СтруктураШапкиДокумента.ПодразделениеОрганизации, СтруктураШапкиДокумента.ПодразделениеОрганизации);
		
		// Сделаем проводку по счету МЦ.
		Проводка = Проводки.Добавить();        
		
		Проводка.Период      = СтруктураШапкиДокумента.Дата;
		Проводка.Организация = СтруктураШапкиДокумента.Организация;
		Проводка.Содержание  = "Возврат " + МПЗ + " из эксплуатации";
		Проводка.Сумма       = СуммаСписанияЗБ;
		
		Если СтрокаТЧ.ТабличнаяЧасть = "Спецодежда" Тогда
			Проводка.СчетКт = ПланыСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный;
		ИначеЕсли СтрокаТЧ.ТабличнаяЧасть = "Спецоснастка" Тогда
			Проводка.СчетКт = ПланыСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный;
		КонецЕсли;
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "Номенклатура",                  СтрокаТЧ.Номенклатура);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ПартииМатериаловВЭксплуатации", СтрокаТЧ.ПартияМатериаловВЭксплуатации);
		БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 3,                               СтрокаТЧ.ПодразделениеФизЛицо);
		Проводка.КоличествоКт = СтрокаТЧ.Количество;
		Проводка.СуммаПРКт    = СуммаСписанияПРЗБ;
		Проводка.СуммаВРКт    = СуммаСписанияВРЗБ;
		
		БухгалтерскийУчет.УстановитьПодразделениеПроводки(Проводка, СтруктураШапкиДокумента.ПодразделениеОрганизации, "Кт");
		
	КонецЦикла;
	
КонецПроцедуры // ДвиженияПоРегистрамРегл()

// Процедура вызывается из тела процедуры ДвиженияПоРегистрам
// Формирует движения по регистрам подсистемы учета НДС "НДСПокупки" 
Процедура ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, ТаблицаПоМатериалам, Отказ, Заголовок)

	Если Не ОбщегоНазначения.ПроводитьДокументПоРазделуУчета(СтруктураШапкиДокумента.Организация, Перечисления.РазделыУчета.НДС, СтруктураШапкиДокумента.Дата) Тогда
		Возврат;
	КонецЕсли;
	
	Если СтруктураШапкиДокумента.ОрганизацияПрименяетУСН тогда
		// Движения по этому документу делать не нужно
		Возврат;
	КонецЕсли;
	
	Если ТаблицаПоМатериалам.Количество()=0  Тогда
		// Движения по этому документу делать не нужно
		Возврат;
	КонецЕсли; 
	СтруктураКолонок = Новый Структура("СчетФактура, Партия,Склад, ВидЦенности,Номенклатура,СчетУчетаНДС, СтавкаНДС, Количество");
	СтруктураКолонок.Вставить("СчетУчета","СчетУчетаЦенности");
	
	ТаблицаПриходуемыхМПЗ = ОбщегоНазначения.СформироватьТаблицуЗначений(ТаблицаПоМатериалам,СтруктураКолонок,, Истина);
	
	ТаблицаПриходуемыхМПЗ.ЗаполнитьЗначения(СтруктураШапкиДокумента.Ссылка,"Партия");
	ТаблицаПриходуемыхМПЗ.ЗаполнитьЗначения(СтруктураШапкиДокумента.Склад,"Склад");
	
	УчетНДС.СформироватьДвиженияПоступленияПоРегиструНДСПоПриобретеннымЦенностям(СтруктураШапкиДокумента,ТаблицаПриходуемыхМПЗ, Движения.НДСПоПриобретеннымЦенностям, Отказ);
	
КонецПроцедуры

// Формирование движений по регистрам налогового учета УСН(регламентированный учет).
//
Процедура ДвиженияПоРегистрамУСНРегл(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериалам, Отказ, Заголовок)
	
	Если Не СтруктураШапкиДокумента.ОтражатьВНалоговомУчетеУСН Тогда
		Возврат;
	КонецЕсли;
	
	Если ТаблицаПоМатериалам.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	//ПО РЕГИСТРУ РАСХОДОВ УСН
	Движения.РасходыПриУСН.Очистить();
	НаборДвижений = Движения.РасходыПриУСН;
	
	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.ВыгрузитьКолонки();
	
	СуммаСторно = 0;
	
	НалоговыйУчетУСН.ПоступлениеРасходовУСН(СтруктураШапкиДокумента, ТаблицаПоМатериалам, ТаблицаДвижений, 
	Перечисления.ВидыРасходовУСН.Номенклатура, Неопределено,
	Перечисления.СтатусыПартийУСН.Купленные, ,Истина, СуммаСторно);
	
	//Недостающие поля.
	ТаблицаДвижений.ЗаполнитьЗначения(Организация, "Организация");
	ТаблицаДвижений.ЗаполнитьЗначения(Дата, "Период");
	ТаблицаДвижений.ЗаполнитьЗначения(Ссылка, "Регистратор");
	ТаблицаДвижений.ЗаполнитьЗначения(Истина, "Активность");
	
	НаборДвижений.мПериод            = Дата;
	НаборДвижений.мТаблицаДвижений   = ТаблицаДвижений;
	
	Если Не Отказ Тогда
		Движения.РасходыПриУСН.ВыполнитьПриход();
		НаборДвижений.Записать(Истина);
	КонецЕсли;
	
	//ПО РЕГИСТРУ КУДиР
	Если СуммаСторно <> 0 Тогда
		КУДиР = Движения.КнигаУчетаДоходовИРасходов;
		
		СтрокаКниги  = КУДиР.Добавить();
		
		СтрокаКниги.Организация     = СтруктураШапкиДокумента.Организация;
		СтрокаКниги.СтрокаДокумента = 0;
		СтрокаКниги.Период          = СтруктураШапкиДокумента.Дата;
		СтрокаКниги.Содержание      = "Материальные расходы уменьшены на сумму спецодежды и спецоснастки, возвращенной из эксплуатации.";
		СтрокаКниги.Графа7          = - СуммаСторно;
		СтрокаКниги.РеквизитыПервичногоДокумента = НалоговыйУчетУСН.РеквизитыПервичногоДокумента(Ссылка);
		
	КонецЕсли;
		
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события ОбработкаПроведения
//
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	СтруктураШапкиДокумента = ПроверкаРеквизитов(Отказ);
	мУчетнаяПолитика = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(КонецМесяца(Дата), Отказ, Организация);
	
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Проверка ручной корректировки
	Если ОбщегоНазначения.РучнаяКорректировкаОбработкаПроведения(РучнаяКорректировка,Отказ,Заголовок,ЭтотОбъект) Тогда
		Возврат
	КонецЕсли;
	
	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);
	
	// Подготовим таблицу материалов для проведения.
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("Ссылка",        Ссылка);
	Запрос.УстановитьПараметр("Период",        СтруктураШапкиДокумента.Дата);
	Запрос.УстановитьПараметр("Организация",   СтруктураШапкиДокумента.Организация);
	Запрос.УстановитьПараметр("Подразделение", СтруктураШапкиДокумента.ПодразделениеОрганизации);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Ссылка,
	|	МИНИМУМ(ВозвратМатериаловИзЭксплуатацииСпецодежда.НомерСтроки) КАК НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо,
	|	СУММА(ВозвратМатериаловИзЭксплуатацииСпецодежда.Количество) КАК Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ОтражениеВУСН
	|ПОМЕСТИТЬ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда
	|ИЗ
	|	Документ.ВозвратМатериаловИзЭксплуатации.Спецодежда КАК ВозвратМатериаловИзЭксплуатацииСпецодежда
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ОтражениеВУСН
	|;
	|
	|ВЫБРАТЬ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка,
	|	МИНИМУМ(ВозвратМатериаловИзЭксплуатацииСпецоснастка.НомерСтроки) КАК НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации,
	|	СУММА(ВозвратМатериаловИзЭксплуатацииСпецоснастка.Количество) КАК Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ОтражениеВУСН
	|ПОМЕСТИТЬ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка
	|ИЗ
	|	Документ.ВозвратМатериаловИзЭксплуатации.Спецоснастка КАК ВозвратМатериаловИзЭксплуатацииСпецоснастка
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ОтражениеВУСН
	|;
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ 
	|	СчетПередачи КАК СчетУчета
	|ПОМЕСТИТЬ 
	|	СчетаУчета
	|ИЗ 
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда
	|
	|ОБЪЕДИНИТЬ 
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ 
	|	СчетПередачи 
	|ИЗ 
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка
	|
	|ОБЪЕДИНИТЬ 
	|
	|ВЫБРАТЬ 
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный)
	|
	|ОБЪЕДИНИТЬ 
	|
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный)
	|;
	|
	|ВЫБРАТЬ
	|	ХозрасчетныйОстатки.Счет,
	|	ХозрасчетныйОстатки.Субконто1,
	|	ХозрасчетныйОстатки.Субконто2,
	|	ХозрасчетныйОстатки.Субконто3,
	|	ХозрасчетныйОстатки.СуммаОстатокДт,
	|	ХозрасчетныйОстатки.СуммаПРОстатокДт,
	|	ХозрасчетныйОстатки.СуммаВРОстатокДт,
	|	ХозрасчетныйОстатки.КоличествоОстатокДт
	|ПОМЕСТИТЬ
	|   ХозрасчетныйОстатки
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки(&Период, 
	|	                                        Счет В (ВЫБРАТЬ СчетУчета ИЗ СчетаУчета),
	|	                                        ,
	|	                                        Организация = &Организация 
	|	                                        И (Подразделение = &Подразделение ИЛИ Подразделение ЕСТЬ NULL) 
	|	                                        И (Субконто2 ССЫЛКА Документ.ПередачаМатериаловВЭксплуатацию
	|	                                           ИЛИ Субконто2 ССЫЛКА Документ.ПартияМатериаловВЭксплуатации)) КАК ХозрасчетныйОстатки	
	|ДЛЯ ИЗМЕНЕНИЯ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки
	|ИНДЕКСИРОВАТЬ ПО
	|	Счет,
	|	Субконто1,
	|	Субконто2,
	|	Субконто3
	|;
	|
	|ВЫБРАТЬ
	|	""Спецодежда""                                                                             КАК ТабличнаяЧасть,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Ссылка                                           КАК Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.НомерСтроки                                      КАК НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                                     КАК Номенклатура,
	|	ПередачаМатериаловВЭксплуатациюСпецодежда.НазначениеИспользования.СпособПогашенияСтоимости КАК СпособПогашенияСтоимости,
	|	ПередачаМатериаловВЭксплуатациюСпецодежда.НазначениеИспользования.СпособОтраженияРасходов  КАК СпособОтраженияРасходов,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации                    КАК ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                                          КАК ПодразделениеФизЛицо,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Количество                                       КАК Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетУчета                                        КАК СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи                                     КАК СчетПередачи,
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный)                   КАК СчетЗабалансовый,
	|	&Подразделение                                                                             КАК ПодразделениеОрганизации,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаОстатокДт, 0)                                            КАК СуммаОстаток,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаПРОстатокДт, 0)                                          КАК СуммаПРОстаток,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаВРОстатокДт, 0)                                          КАК СуммаВРОстаток,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстатокДт, 0)                                       КАК КоличествоОстаток,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаОстатокДт, 0)                                          КАК СуммаОстатокЗБ,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаПРОстатокДт, 0)                                        КАК СуммаПРОстатокЗБ,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаВРОстатокДт, 0)                                        КАК СуммаВРОстатокЗБ,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.КоличествоОстатокДт, 0)                                     КАК КоличествоОстатокЗБ,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ОтражениеВУСН                                    КАК ОтражениеВУСН
	|ИЗ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПередачаМатериаловВЭксплуатацию.Спецодежда КАК ПередачаМатериаловВЭксплуатациюСпецодежда
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                  = ПередачаМатериаловВЭксплуатациюСпецодежда.Номенклатура
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации = ПередачаМатериаловВЭксплуатациюСпецодежда.Ссылка
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                       = ПередачаМатериаловВЭксплуатациюСпецодежда.ФизЛицо
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи                  = ХозрасчетныйОстатки.Счет
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                  = ХозрасчетныйОстатки.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации = ХозрасчетныйОстатки.Субконто2
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                       = ХозрасчетныйОстатки.Субконто3
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки КАК ХозрасчетныйОстаткиЗБ 
	|		ПО ХозрасчетныйОстаткиЗБ.Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный)
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                  = ХозрасчетныйОстаткиЗБ.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации = ХозрасчетныйОстаткиЗБ.Субконто2
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                       = ХозрасчетныйОстаткиЗБ.Субконто3
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации ССЫЛКА Документ.ПередачаМатериаловВЭксплуатацию
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	""Спецодежда"",
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации.НазначениеИспользования.СпособПогашенияСтоимости,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации.НазначениеИспользования.СпособОтраженияРасходов,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи,
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный),
	|	&Подразделение,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.КоличествоОстатокДт, 0),
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ОтражениеВУСН
	|ИЗ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецодежда.СчетПередачи                  = ХозрасчетныйОстатки.Счет
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                  = ХозрасчетныйОстатки.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации = ХозрасчетныйОстатки.Субконто2
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                       = ХозрасчетныйОстатки.Субконто3
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки КАК ХозрасчетныйОстаткиЗБ
	|		ПО ХозрасчетныйОстаткиЗБ.Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный)
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.Номенклатура                  = ХозрасчетныйОстаткиЗБ.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации = ХозрасчетныйОстаткиЗБ.Субконто2
	|		 И ВозвратМатериаловИзЭксплуатацииСпецодежда.ФизЛицо                       = ХозрасчетныйОстаткиЗБ.Субконто3
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецодежда.ПартияМатериаловВЭксплуатации ССЫЛКА Документ.ПартияМатериаловВЭксплуатации
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	""Спецоснастка"",
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура,
	|	ПередачаМатериаловВЭксплуатациюСпецоснастка.НазначениеИспользования.СпособПогашенияСтоимости,
	|	ПередачаМатериаловВЭксплуатациюСпецоснастка.НазначениеИспользования.СпособОтраженияРасходов,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка.ПодразделениеОрганизации КАК ПодразделениеОрганизацииФизЛицо,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи,
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный),
	|	&Подразделение,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.КоличествоОстатокДт, 0),
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ОтражениеВУСН
	|ИЗ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПередачаМатериаловВЭксплуатацию.Спецоснастка КАК ПередачаМатериаловВЭксплуатациюСпецоснастка
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура                    = ПередачаМатериаловВЭксплуатациюСпецоснастка.Номенклатура
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации   = ПередачаМатериаловВЭксплуатациюСпецоснастка.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи                    = ХозрасчетныйОстатки.Счет
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура                    = ХозрасчетныйОстатки.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации   = ХозрасчетныйОстатки.Субконто2
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки КАК ХозрасчетныйОстаткиЗБ
	|		ПО ХозрасчетныйОстаткиЗБ.Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный)
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура                    = ХозрасчетныйОстаткиЗБ.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации   = ХозрасчетныйОстаткиЗБ.Субконто2
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации ССЫЛКА Документ.ПередачаМатериаловВЭксплуатацию
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	""Спецоснастка"",
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.НомерСтроки,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации.НазначениеИспользования.СпособПогашенияСтоимости,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации.НазначениеИспользования.СпособОтраженияРасходов,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Ссылка.ПодразделениеОрганизации,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.Количество,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетУчета,
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи,
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный),
	|	&Подразделение,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаПРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.СуммаВРОстатокДт, 0),
	|	ЕСТЬNULL(ХозрасчетныйОстаткиЗБ.КоличествоОстатокДт, 0),
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ОтражениеВУСН
	|ИЗ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки
	|		ПО ВозвратМатериаловИзЭксплуатацииСпецоснастка.СчетПередачи                    = ХозрасчетныйОстатки.Счет
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура                    = ХозрасчетныйОстатки.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации   = ХозрасчетныйОстатки.Субконто2
	|		ЛЕВОЕ СОЕДИНЕНИЕ ХозрасчетныйОстатки КАК ХозрасчетныйОстаткиЗБ
	|		ПО ХозрасчетныйОстаткиЗБ.Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный)
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.Номенклатура                    = ХозрасчетныйОстаткиЗБ.Субконто1
	|		 И ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации   = ХозрасчетныйОстаткиЗБ.Субконто2
	|ГДЕ
	|	ВозвратМатериаловИзЭксплуатацииСпецоснастка.ПартияМатериаловВЭксплуатации ССЫЛКА Документ.ПартияМатериаловВЭксплуатации
	|";
	
	ТаблицаПоМатериалам = Запрос.Выполнить().Выгрузить();	
	
	// Движения по документу.
	Если НЕ Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоМатериалам, Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры	// ОбработкаПроведения()

// Процедура - обработчик события ОбработкаЗаполнения
//
Процедура ОбработкаЗаполнения(Основание)
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПередачаМатериаловВЭксплуатацию") Тогда
		
		// Заполнение шапки
		Организация                  = Основание.Организация;
		ПодразделениеОрганизации     = Основание.Местонахождение;
		Склад                        = Основание.Склад;
		Комментарий                  = Основание.Комментарий;
		Ответственный                = Основание.Ответственный;
		
		Для Каждого ТекСтрокаСпецодежда Из Основание.Спецодежда Цикл
			
			Если ЗначениеЗаполнено(ТекСтрокаСпецодежда.НазначениеИспользования) 
			   И ТекСтрокаСпецодежда.НазначениеИспользования.СпособПогашенияСтоимости = Перечисления.СпособыПогашенияСтоимости.ПогашатьСтоимостьПриПередачеВЭксплуатацию Тогда
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = Спецодежда.Добавить();
			
			НоваяСтрока.Номенклатура                  = ТекСтрокаСпецодежда.Номенклатура;
			НоваяСтрока.ФизЛицо                       = ТекСтрокаСпецодежда.ФизЛицо;
			НоваяСтрока.ПартияМатериаловВЭксплуатации = Основание;
			НоваяСтрока.Количество                    = ТекСтрокаСпецодежда.Количество;
			НоваяСтрока.СчетУчета                     = ТекСтрокаСпецодежда.СчетУчета;
			НоваяСтрока.СчетПередачи                  = ТекСтрокаСпецодежда.СчетПередачи;
			
		КонецЦикла;
		
		Для Каждого ТекСтрокаСпецоснастка Из Основание.Спецоснастка Цикл
			
			Если ЗначениеЗаполнено(ТекСтрокаСпецоснастка.НазначениеИспользования) 
			   И ТекСтрокаСпецоснастка.НазначениеИспользования.СпособПогашенияСтоимости = Перечисления.СпособыПогашенияСтоимости.ПогашатьСтоимостьПриПередачеВЭксплуатацию Тогда
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = Спецоснастка.Добавить();
			
			НоваяСтрока.Номенклатура                  = ТекСтрокаСпецоснастка.Номенклатура;
			НоваяСтрока.ПартияМатериаловВЭксплуатации = Основание;
			НоваяСтрока.Количество                    = ТекСтрокаСпецоснастка.Количество;
			НоваяСтрока.СчетУчета                     = ТекСтрокаСпецоснастка.СчетУчета;
			НоваяСтрока.СчетПередачи                  = ТекСтрокаСпецоснастка.СчетПередачи;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, РучнаяКорректировка, ложь);

КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();

