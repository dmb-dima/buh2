﻿Перем мВалютаРегламентированногоУчета Экспорт;

Перем мУчетнаяПолитикаНУ Экспорт;

Перем мВестиУчетНДС Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ АВТОЗАПОЛНЕНИЯ СТРОК ДОКУМЕНТА

//Процедура заполнения табличной части по данным подсистемы НДС
Процедура ЗаполнитьДокумент(ОшибкаЗаполнения = Ложь, Сообщать = Истина, СтрокаСообщения = "", ОтменитьПроведение = Ложь) Экспорт
	
	Если Проведен Тогда
		Если ОтменитьПроведение Тогда
			Записать(РежимЗаписиДокумента.ОтменаПроведения);
		Иначе
			ОшибкаЗаполнения = Истина;
			СтрокаСообщения = " перед заполнением требуется отменить проведение документа";
			Если Сообщать Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Документ не заполнен:" + СтрокаСообщения, , Строка(Ссылка));
			КонецЕсли; 
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьСтроки_СМРхозспособом();

	Если Не (СМРхозспособом.Количество() > 0 
        ) Тогда
		ОшибкаЗаполнения = Истина;
		СтрокаСообщения = СтрокаСообщения+Символы.ПС+" - не обнаружены расходы на строительство хоз. способом, начисление НДС не требуется"
	КонецЕсли;	

   Если ОшибкаЗаполнения Тогда
		Если Сообщать Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Документ не заполнен:"+СтрокаСообщения,,Строка(Ссылка));
		КонецЕсли; 
		Возврат;
	КонецЕсли; 
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Заполнение табличной части "СМР хозспособом"

// Процедура выполняет автоматическое заполнение табличной части документа
// Вызывается из процедуры КоманднаяПанельВычетПоПриобретеннымЦенностямЗаполнить
//
Процедура ЗаполнитьСтроки_СМРхозспособом() Экспорт
	
	ТаблицаРезультатов = СМРхозспособом.ВыгрузитьКолонки();
	
	НачалоПериода	= УчетНДС.ПолучитьНачалоПериодаПоУчетнойПолитике(Организация, Дата, Ложь);
	КонецПериода	= УчетНДС.ПолучитьКонецПериодаПоУчетнойПолитике(Организация, Дата, Ложь);	
	
	Если мУчетнаяПолитикаНУ.УпрощенныйУчетНДС Тогда
		ТаблицаРезультатов = ЗаполнитьСМРхозспособомПоУказанномуПериоду_УпрощенныйНДС(НачалоПериода, КонецПериода);	
	Иначе
		ТаблицаРезультатов = ЗаполнитьСМРхозспособомПоУказанномуПериоду(НачалоПериода, КонецПериода);
	КонецЕсли;
		
	СМРхозспособом.Загрузить(ТаблицаРезультатов);
	
	СМРхозспособом.Сортировать("ОбъектСтроительства");

КонецПроцедуры // ЗаполнитьСтрокиДокумента()

// Вызывается из процедуры ЗаполнитьСтроки_СМРхозспособом.
// Заполняет ТЧ СМРхозспособом по данным указанного периода
Функция ЗаполнитьСМРхозспособомПоУказанномуПериоду(НачалоПериода, КонецПериода)

	Перем Подразделение;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СтроительствоХозспособом.Объект КАК ОбъектСтроительства,
	|	СУММА(СтроительствоХозспособом.Сумма) КАК СуммаБезНДС,
	|	&СтавкаНДС КАК СтавкаНДС,
	|	СУММА(СтроительствоХозспособом.Сумма * &СтавкаНДС_Значение / 100) КАК НДС
	|ИЗ
	|	(ВЫБРАТЬ
	|		ХозрасчетныйОбороты.Субконто1 КАК Объект,
	|		ХозрасчетныйОбороты.СуммаОборотДт КАК Сумма
	|	ИЗ
	|		РегистрБухгалтерии.Хозрасчетный.Обороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				Период,
	|				Счет В ИЕРАРХИИ (&СчетУчетаСтроительства),
	|				&ВидыСубконто,
	|				Организация = &Организация И Истина
	|					И (Подразделение = &Подразделение ИЛИ Подразделение ЕСТЬ NULL)
	|					И Субконто2 = &ВидСтроительства_Хозспособом,
	|				,
	|				) КАК ХозрасчетныйОбороты
	|	ГДЕ
	|		ХозрасчетныйОбороты.СуммаОборотДт > 0
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		НДСпоОСиНМАОбороты.Объект,
	|		(НДСпоОСиНМАОбороты.СуммаБезНДСПриход + ВЫБОР
	|			КОГДА НДСпоОСиНМАОбороты.НДСВключенВСтоимость
	|				ТОГДА НДСпоОСиНМАОбороты.НДСПриход
	|			ИНАЧЕ 0
	|		КОНЕЦ) * -1
	|	ИЗ
	|		РегистрНакопления.НДСпоОСиНМА.Обороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				Период,
	|				Организация = &Организация
	|					И СчетФактура ССЫЛКА Документ.НачислениеНДСпоСМРхозспособом
	|					И ВидЦенности = &ВидЦенности_Хозспособом
	|					И Состояние = &Состояние_НачислениеПоХозспособу) КАК НДСпоОСиНМАОбороты) КАК СтроительствоХозспособом
	|
	|СГРУППИРОВАТЬ ПО
	|	СтроительствоХозспособом.Объект
	|
	|ИМЕЮЩИЕ
	|	СУММА(СтроительствоХозспособом.Сумма) > 0";
	
	// {ОбособленныеПодразделения
	Подразделение = ПодразделениеОрганизации;
	// }ОбособленныеПодразделения
	
	Запрос.УстановитьПараметр("Организация"		, Организация);
	Запрос.УстановитьПараметр("Подразделение"	, Подразделение);
	Запрос.УстановитьПараметр("НачалоПериода"	, новый граница(НачалоПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("КонецПериода"	, новый граница(КонецПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("СчетУчетаСтроительства", ПланыСчетов.Хозрасчетный.СтроительствоОбъектовОсновныхСредств);
	ВидыСубконто = Новый Массив();
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ОбъектыСтроительства);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СпособыСтроительства);
	Запрос.УстановитьПараметр("ВидыСубконто"	, ВидыСубконто);
	Запрос.УстановитьПараметр("ВидСтроительства_Хозспособом"	, Перечисления.СпособыСтроительства.Хозспособ);
	Запрос.УстановитьПараметр("ВидЦенности_Хозспособом"			, Перечисления.ВидыЦенностей.СМРСобственнымиСилами);
	Запрос.УстановитьПараметр("Состояние_НачислениеПоХозспособу", Перечисления.НДССостоянияОСНМА.ОжидаетсяПринятиеКУчетуОбъектаСтроительства);
	// Ставка НДС для начисления по хозспособу по умолчанию 18%
	Запрос.УстановитьПараметр("СтавкаНДС"						, Перечисления.СтавкиНДС.НДС18);
	Запрос.УстановитьПараметр("СтавкаНДС_Значение"				, УчетНДС.ПолучитьСтавкуНДС(Перечисления.СтавкиНДС.НДС18));
	
	ТаблицаРезультатов = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
	
	Возврат ТаблицаРезультатов;
	
КонецФункции // ЗаполнитьНДСКВычетуПоДаннымРегистраНДСПредъявленный()

Функция ЗаполнитьСМРхозспособомПоУказанномуПериоду_УпрощенныйНДС(НачалоПериода, КонецПериода)

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ХозрасчетныйОбороты.Субконто1 КАК ОбъектСтроительства,
	|	ХозрасчетныйОбороты.СуммаОборотДт КАК СуммаБезНДС,
	|	&СтавкаНДС КАК СтавкаНДС,
	|	ХозрасчетныйОбороты.СуммаОборотДт * &СтавкаНДС_Значение / 100 КАК НДС
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			Период,
	|			Счет В ИЕРАРХИИ (&СчетУчетаСтроительства),
	|			&ВидыСубконто,
	|			Организация = &Организация
	|				И Субконто2 = &ВидСтроительства_Хозспособом,
	|			,
	|			) КАК ХозрасчетныйОбороты
	|ГДЕ
	|	ХозрасчетныйОбороты.СуммаОборотДт > 0";

	Запрос.УстановитьПараметр("Организация"		, Организация);
	Запрос.УстановитьПараметр("НачалоПериода"	, новый граница(НачалоПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("КонецПериода"	, новый граница(КонецПериода,ВидГраницы.Включая));
	Запрос.УстановитьПараметр("СчетУчетаСтроительства", ПланыСчетов.Хозрасчетный.СтроительствоОбъектовОсновныхСредств);
	ВидыСубконто = Новый Массив();
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ОбъектыСтроительства);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.СпособыСтроительства);
	Запрос.УстановитьПараметр("ВидыСубконто"	, ВидыСубконто);
	Запрос.УстановитьПараметр("ВидСтроительства_Хозспособом"	, Перечисления.СпособыСтроительства.Хозспособ);
	// Ставка НДС для начисления по хозспособу по умолчанию 18%
	Запрос.УстановитьПараметр("СтавкаНДС"						, Перечисления.СтавкиНДС.НДС18);
	Запрос.УстановитьПараметр("СтавкаНДС_Значение"				, УчетНДС.ПолучитьСтавкуНДС(Перечисления.СтавкиНДС.НДС18));
	
	ТаблицаРезультатов = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
	
	Возврат ТаблицаРезультатов;
	
КонецФункции // ЗаполнитьНДСКВычетуПоДаннымРегистраНДСПредъявленный()
// Заполнение табличной части "СМР хозспособом"
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

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

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	// Документ может быть введен не ранее 31.12.2005.
	// В нем отрабатываются положения НК РФ, вступающие в силу с 01.01.2006 г.
	// а так же положения переходного периода (последним дням 2005 года)
	Если СтруктураШапкиДокумента.Дата<'20051231' Тогда
		ОбщегоНазначения.ОшибкаПриПроведении("Документ не может быть проведен с датой менее 31 декабря 2005 года!",Отказ, Заголовок);
	КонецЕсли; 
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// По организации не может быть введено более одного документа данного вида за месяц 
//
Процедура ПроверитьСуществованиеДругихДокументовВТекущемПериоде(СтруктураШапкиДокумента, Отказ,Заголовок)
	
	ЗаполнениеПоТекущемуНалоговомуПериоду = ( не НачалоДня(Дата) < '20060101');
	
	Если ЗаполнениеПоТекущемуНалоговомуПериоду Тогда
	    НачалоПериода	= УчетНДС.ПолучитьНачалоПериодаПоУчетнойПолитике(Организация, Дата, Отказ, мУчетнаяПолитикаНУ);
		КонецПериода	= УчетНДС.ПолучитьКонецПериодаПоУчетнойПолитике(Организация, Дата, Отказ, мУчетнаяПолитикаНУ);	
	Иначе
	    НачалоПериода	= '20050101';
		КонецПериода	= '20051231235959';	
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НачислениеНДСпоСМРхозспособом.Ссылка,
	|	НачислениеНДСпоСМРхозспособом.Представление
	|ИЗ
	|	Документ.НачислениеНДСпоСМРхозспособом КАК НачислениеНДСпоСМРхозспособом
	|ГДЕ
	|	НачислениеНДСпоСМРхозспособом.Дата >= &НачалоПериода
	|	И НачислениеНДСпоСМРхозспособом.Дата <= &КонецПериода
	|	И НачислениеНДСпоСМРхозспособом.Организация = &Организация
	|	И (НЕ НачислениеНДСпоСМРхозспособом.Ссылка = &ТекущийДокумент)
	|	И НачислениеНДСпоСМРхозспособом.Проведен = ИСТИНА";
	
	Запрос.УстановитьПараметр("НачалоПериода",	НачалоДня(НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",	КонецДня(КонецПериода));
	Запрос.УстановитьПараметр("Организация",	СтруктураШапкиДокумента.Организация);
	Запрос.УстановитьПараметр("ТекущийДокумент",СтруктураШапкиДокумента.Ссылка);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
	    Возврат;
	КонецЕсли; 
	
	СтрокаДокументовПересечений = "";
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если НЕ ПустаяСтрока(СтрокаДокументовПересечений) Тогда
			СтрокаДокументовПересечений = СтрокаДокументовПересечений + Символы.ПС;
		КонецЕсли; 
		СтрокаДокументовПересечений = СтрокаДокументовПересечений + Строка(Выборка.Представление);
	КонецЦикла; 
	
	Если НЕ ПустаяСтрока(СтрокаДокументовПересечений) Тогда
		ОбщегоНазначения.ОшибкаПриПроведении(("Найдены документы по начислению НДС по СМР хозспособом, которые действуют в выбранном периоде("+ПредставлениеПериода(НачалоДня(НачалоПериода), КонецДня(КонецПериода), "ФП = Истина")+"):" + Символы.ПС + СтрокаДокументовПересечений), Отказ, Заголовок);
	КонецЕсли; 
	
КонецПроцедуры // ПроверитьСуществованиеДругихДокументовВТекущемМесяце(СтруктураШапкиДокумента)()
 
// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
//
Функция ПодготовитьТаблицуПоСМРхозспособом(РезультатЗапросаПоСМРхозспособом, СтруктураШапкиДокумента)

	ТаблицаСМРхозспособом = РезультатЗапросаПоСМРхозспособом.Выгрузить();
	
	ТаблицаСМРхозспособом.Колонки.Добавить("ВидЦенности", Новый ОписаниеТипов("ПеречислениеСсылка.ВидыЦенностей"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(Перечисления.ВидыЦенностей.СМРСобственнымиСилами, "ВидЦенности");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("Состояние", Новый ОписаниеТипов("ПеречислениеСсылка.НДССостоянияОСНМА"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(Перечисления.НДССостоянияОСНМА.ОжидаетсяПринятиеКУчетуОбъектаСтроительства, "Состояние");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("СчетУчетаНДС", Новый ОписаниеТипов("ПланСчетовСсылка.Хозрасчетный"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДСприСтроительствеОсновныхСредств, "СчетУчетаНДС");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("СчетУчетаНДСПоРеализации", Новый ОписаниеТипов("ПланСчетовСсылка.Хозрасчетный"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДСприСтроительствеОсновныхСредств, "СчетУчетаНДСПоРеализации");
	
	ТаблицаСМРхозспособом.Колонки.Добавить("НеВлияетНаВычет", Новый ОписаниеТипов("Булево"));
	ТаблицаСМРхозспособом.ЗаполнитьЗначения(Истина, "НеВлияетНаВычет");
	
	Если СтруктураШапкиДокумента.УпрощенныйУчетНДС Тогда
		ТаблицаСМРхозспособом.Колонки.Добавить("Событие", Новый ОписаниеТипов("ПеречислениеСсылка.СобытияПоНДСПродажи"));
		ТаблицаСМРхозспособом.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПродажи.НДСНачисленКУплате, "Событие");
	КонецЕсли;
	
	ТаблицаСМРхозспособом.Колонки.Добавить("Сумма", ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15, 2));
	ТаблицаСМРхозспособом.ЗагрузитьКолонку(ТаблицаСМРхозспособом.ВыгрузитьКолонку("СуммаБезНДС"), "Сумма");
	
	Возврат ТаблицаСМРхозспособом;

КонецФункции // ПодготовитьТаблицуПоОплатам()

// Проверяет правильность заполнения строк табличной части.
//
//
Процедура ПроверитьЗаполнениеТабличнойЧастиПоСМРхозспособом(СтруктураШапкиДокумента,ТаблицаПоСМРхозспособом, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("ОбъектСтроительства, СтавкаНДС"); 
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "СМРхозспособом", СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// По результату запроса по шапке документа формируем движения по регистрам.
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Отказ, Заголовок)
	
	ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Отказ, Заголовок);
	
	Если СтруктураШапкиДокумента.УпрощенныйУчетНДС Тогда
		УчетНДСФормированиеДвижений.УпрощенныйНДС_СформироватьДвиженияПоНДСНачисленному(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Движения, Отказ);
	Иначе
		ДвиженияПоРегистрамНДС_НачислениеСМРхозспособом(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Отказ, Заголовок)
	
	Для Каждого СтрокаНачисления Из ТаблицаПоСМРхозспособом Цикл
		
		Если СтрокаНачисления.НДС <> 0 Тогда
			// Проводка по уплате НДС в бюджет
			ПроводкаБУ = Движения.Хозрасчетный.Добавить();
			ПроводкаБУ.Период = СтруктураШапкиДокумента.Дата;
			ПроводкаБУ.Организация = СтруктураШапкиДокумента.Организация;
			ПроводкаБУ.Содержание = "Начислен НДС по строительству хоз. способом";
			
			ПроводкаБУ.СчетДт = СтрокаНачисления.СчетУчетаНДС;
			БухгалтерскийУчет.УстановитьСубконто(ПроводкаБУ.СчетДт, ПроводкаБУ.СубконтоДт, "ОбъектыСтроительства", СтрокаНачисления.Объект);
			БухгалтерскийУчет.УстановитьСубконто(ПроводкаБУ.СчетДт, ПроводкаБУ.СубконтоДт, "СФПолученные", СтрокаНачисления.СчетФактура, Истина);
			
			ПроводкаБУ.СчетКт = ПланыСчетов.Хозрасчетный.НДС;
			БухгалтерскийУчет.УстановитьСубконто(ПроводкаБУ.СчетКт, ПроводкаБУ.СубконтоКт, "ВидыПлатежейВГосБюджет", Перечисления.ВидыПлатежейВГосБюджет.Налог);
			
			ПроводкаБУ.Сумма = СтрокаНачисления.НДС;
		КонецЕсли; 
		
	КонецЦикла;
		
КонецПроцедуры

// По результату запроса по шапке документа формируем движения по регистрам.
// Отрабатывает по табличной части "СМРхозспособом"
//
Процедура ДвиженияПоРегистрамНДС_НачислениеСМРхозспособом(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом, Отказ, Заголовок)

	Если ТаблицаПоСМРхозспособом.КОличество()=0 Тогда
		Возврат;
	КонецЕсли; 
	
	Если мВестиУчетНДС Тогда
		// Отражение по регистру "НДС начисленный"
		ТаблицаДвижений_НДСНачисленный = Движения.НДСНачисленный.ВыгрузитьКолонки();
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоСМРхозспособом,ТаблицаДвижений_НДСНачисленный);
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(ПланыСчетов.Хозрасчетный.НДС,"СчетУчетаНДС");
		ТаблицаДвижений_НДСНачисленный.Свернуть("Период,Активность,Организация,СчетФактура,ВидЦенности,СтавкаНДС,СчетУчетаНДС,Покупатель,ДатаСобытия,Событие,ВидНачисления","СуммаБезНДС,НДС");
		
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПродажи.НДСНачисленКУплате,"Событие");
		ТаблицаДвижений_НДСНачисленный.ЗаполнитьЗначения(Перечисления.НДСВидНачисления.НДСНачисленКУплате,"ВидНачисления");
		
		Движения.НДСНачисленный.мПериод = СтруктураШапкиДокумента.Дата;
		Движения.НДСНачисленный.мТаблицаДвижений = ТаблицаДвижений_НДСНачисленный;
		Движения.НДСНачисленный.ВыполнитьПриход();
		
		// Отражение по регистру "НДС предъявленный"
		ТаблицаДвижений_НДСПредъявленный = Движения.НДСПредъявленный.ВыгрузитьКолонки();
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоСМРхозспособом,ТаблицаДвижений_НДСПредъявленный);
		ТаблицаДвижений_НДСПредъявленный.Свернуть("Период,Активность,Организация,СчетФактура,ВидЦенности,СтавкаНДС,СчетУчетаНДС,Поставщик,ДатаСобытия,Событие","СуммаБезНДС,НДС");
		ТаблицаДвижений_НДСПредъявленный.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.ПредъявленНДСПоставщиком,"Событие");
		
		
		Движения.НДСПредъявленный.мПериод = СтруктураШапкиДокумента.Дата;
		Движения.НДСПредъявленный.мТаблицаДвижений = ТаблицаДвижений_НДСПредъявленный;
		Движения.НДСПредъявленный.ВыполнитьПриход();
		
		// Отражение по регистру "НДС по ОС, НМА"
		ТаблицаДвижений_НДСпоОСиНМА = Движения.НДСпоОСиНМА.ВыгрузитьКолонки();
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоСМРхозспособом,ТаблицаДвижений_НДСпоОСиНМА);
		ТаблицаДвижений_НДСпоОСиНМА.Свернуть("Период,Активность,Организация,Объект,Состояние, СчетФактура,ВидЦенности,СтавкаНДС,СчетУчетаНДС,ДатаСобытия, Событие,НеВлияетНаВычет","СуммаБезНДС,НДС");
		ТаблицаДвижений_НДСпоОСиНМА.ЗаполнитьЗначения(Перечисления.НДССостоянияОСНМА.ОжидаетсяПринятиеКУчетуОбъектаСтроительства,"Состояние");
		ТаблицаДвижений_НДСпоОСиНМА.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.ПереданНДСНаСтроительство,"Событие");
		ТаблицаДвижений_НДСпоОСиНМА.ЗаполнитьЗначения(Истина,"НеВлияетНаВычет");
		
		Движения.НДСпоОСиНМА.мПериод = СтруктураШапкиДокумента.Дата;
		Движения.НДСпоОСиНМА.мТаблицаДвижений = ТаблицаДвижений_НДСпоОСиНМА;
		Движения.НДСпоОСиНМА.ВыполнитьПриход();
		
	КонецЕсли;

КонецПроцедуры // ДвиженияПоСМРхозспособомНДСпоПриобретеннымЦенностям()

Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ) Экспорт
	
	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	СтруктураШапкиДокумента.Вставить("УпрощенныйУчетНДС", УчетНДС.ПолучитьУПУпрощенныйУчетНДС(Организация, Дата));
	
КонецПроцедуры

Процедура ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом) Экспорт
	
	// Подготовим данные необходимые для проведения и проверки заполнения табличной части.
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация",		"Ссылка.Организация");
	СтруктураПолей.Вставить("СчетФактура",		"Ссылка");
	СтруктураПолей.Вставить("Объект",			"ОбъектСтроительства");
	СтруктураПолей.Вставить("СтавкаНДС",		"СтавкаНДС");
	СтруктураПолей.Вставить("СуммаБезНДС",		"СуммаБезНДС");
	СтруктураПолей.Вставить("НДС",				"НДС");
	
	СтруктураПолей.Вставить("ДатаСобытия",		"Ссылка.Дата");

	РезультатЗапросаСМРхозспособом	= ОбщегоНазначения.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "СМРхозспособом", СтруктураПолей);
	ТаблицаПоСМРхозспособом			= ПодготовитьТаблицуПоСМРхозспособом(РезультатЗапросаСМРхозспособом,СтруктураШапкиДокумента);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Перем СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом;
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Проверка ручной корректировки
	Если ОбщегоНазначения.РучнаяКорректировкаОбработкаПроведения(РучнаяКорректировка,Отказ,Заголовок,ЭтотОбъект) Тогда
		Возврат
	КонецЕсли;

	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ);
	
	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	ПроверитьСуществованиеДругихДокументовВТекущемПериоде(СтруктураШапкиДокумента, Отказ,Заголовок);
	
	ПодготовитьТаблицыДокумента(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом);
	
	ПроверитьЗаполнениеТабличнойЧастиПоСМРхозспособом(СтруктураШапкиДокумента,ТаблицаПоСМРхозспособом, Отказ, Заголовок);
	
	мВестиУчетНДС = УчетНДС.ПроводитьПоРазделуУчетаНДС(Дата);

	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоСМРхозспособом,Отказ, Заголовок);
	КонецЕсли;
	
	Если Не Отказ Тогда
		УниверсальныеМеханизмы.ЗафиксироватьФактВыполненияРегламентнойОперации(НачалоМесяца(Дата),
													  СтруктураШапкиДокумента.Организация,
													  Ссылка,														  
													  Перечисления.РегламентныеОперации.НачислениеНДСпоСМРхозспособом);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	УниверсальныеМеханизмы.СброситьФактВыполненияОперации(Ссылка);
			
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, РучнаяКорректировка, Ложь);
	
	УчетНДС.УстановкаПроведенияУСчетаФактуры(Ссылка, "СчетФактураВыданный", Ложь);

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	мУчетнаяПолитикаНУ = Неопределено;
	
	УчетНДС.СинхронизацияПометкиНаУдалениеУСчетаФактуры(ЭтотОбъект, "СчетФактураВыданный");

	УчетНДС.ПроверитьСоответствиеРеквизитовСчетаФактуры(ЭтотОбъект);
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();

