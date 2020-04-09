﻿////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Формирует запрос по шапке документа
//
// Параметры: 
//  Режим - режим проведения
//
// Возвращаемое значение:
//  Результат запроса
//
Функция СформироватьЗапросПоШапке(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);
	Запрос.УстановитьПараметр("ПустаяОрганизация" , Справочники.Организации.ПустаяСсылка());

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.Дата,
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.Ссылка,
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.Организация,
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.НалоговыйПериод,
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.Ответственный,
	|	ВЫБОР
	|		КОГДА НДФЛПодтверждениеПраваНаИмущественныйВычет.Организация.ГоловнаяОрганизация = &ПустаяОрганизация
	|			ТОГДА НДФЛПодтверждениеПраваНаИмущественныйВычет.Организация
	|		ИНАЧЕ НДФЛПодтверждениеПраваНаИмущественныйВычет.Организация.ГоловнаяОрганизация
	|	КОНЕЦ КАК ГоловнаяОрганизация
	|ИЗ
	|	Документ.НДФЛПодтверждениеПраваНаИмущественныйВычет КАК НДФЛПодтверждениеПраваНаИмущественныйВычет
	|ГДЕ
	|	НДФЛПодтверждениеПраваНаИмущественныйВычет.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

// Формирует запрос по табличной части документам
//
// Параметры: 
//  Режим        - режим проведения.
//
// Возвращаемое значение:
//  Результат запроса.
//
Функция СформироватьЗапросПоРаботникиОрганизации(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТЧРаботникиОрганизации.НомерСтроки,
	|	ТЧРаботникиОрганизации.ФизЛицо,
	|	ТЧРаботникиОрганизации.Расходы,
	|	ТЧРаботникиОрганизации.ПроцентыПоКредитам,
	|	ТЧРаботникиОрганизации.ДатаСобытия,
	|	ТЧРаботникиОрганизации.ПроцентыПриПерекредитовании
	|ИЗ
	|	Документ.НДФЛПодтверждениеПраваНаИмущественныйВычет.РаботникиОрганизации КАК ТЧРаботникиОрганизации
	|ГДЕ
	|	ТЧРаботникиОрганизации.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверка выполняется по выборке из результата запроса по шапке,
// все проверяемые реквизиты должны быть включены в выборку по шапке.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента	- выборка из результата запроса по шапке документа,
//  Отказ 		 - флаг отказа в проведении,
//	Заголовок	 - Заголовок для сообщений об ошибках проведения.
//
Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок)

	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Организация) Тогда
		ОбщегоНазначения.ОшибкаПриПроведении("Не указана организация!", Отказ, Заголовок);
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.НалоговыйПериод) Тогда
		ОбщегоНазначения.ОшибкаПриПроведении("Не указан налоговый период, к доходам которого относится вычет!", Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строки документа.
Процедура ПроверитьЗаполнениеСтрокиРаботникаОрганизации(ВыборкаПоРаботникиОрганизации, Отказ, Заголовок)

	НачалоСообщения = "В строке № """+ СокрЛП(ВыборкаПоРаботникиОрганизации.НомерСтроки) +
						""" табл. части ""Работники организации"": ";
	
	Если НЕ ЗначениеЗаполнено(ВыборкаПоРаботникиОрганизации.ФизЛицо) Тогда
		ОбщегоНазначения.ОшибкаПриПроведении(НачалоСообщения + "не указано физическое лицо!", Отказ, Заголовок);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ВыборкаПоРаботникиОрганизации.ДатаСобытия) Тогда
		ОбщегоНазначения.ОшибкаПриПроведении(НачалоСообщения + "не указана получения права на вычет!", Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// По строке выборки результата запроса по документу формируем движения по регистрам
//
// Параметры: 
//  ВыборкаПоШапкеДокумента                  - выборка из результата запроса по шапке документа
//  СтруктураПроведенияПоРегистрамНакопления - структура, содержащая имена регистров 
//                                             накопления по которым надо проводить документ
//  СтруктураПараметров                      - структура параметров проведения.
//
// Возвращаемое значение:
//  Нет.
//
Процедура ДобавитьСтрокуВДвиженияПоРегистрамНакопления(ВыборкаПоРаботникиОрганизации, ВыборкаПоШапкеДокумента)
	
	Если ВыборкаПоРаботникиОрганизации.Расходы + ВыборкаПоРаботникиОрганизации.ПроцентыПоКредитам + ВыборкаПоРаботникиОрганизации.ПроцентыПриПерекредитовании <> 0 Тогда
		
		Если ВыборкаПоРаботникиОрганизации.Расходы <> 0 Тогда
			
			Движение = Движения.НДФЛИмущественныеВычетыФизлиц.Добавить();
			// Свойства
			Движение.Период                 		= ВыборкаПоРаботникиОрганизации.ДатаСобытия;
			Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
			// Измерения
			Движение.ФизЛицо                		= ВыборкаПоРаботникиОрганизации.ФизЛицо;
			Движение.Организация               		= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
			Движение.Год		               		= ВыборкаПоШапкеДокумента.НалоговыйПериод;
			Движение.КодВычетаИмущественный         = Справочники.ВычетыНДФЛ.Код311;
			// Ресурсы
			Движение.Размер							= ВыборкаПоРаботникиОрганизации.Расходы; 

		КонецЕсли;
		
		Если ВыборкаПоРаботникиОрганизации.ПроцентыПоКредитам <> 0 Тогда
			
			Движение = Движения.НДФЛИмущественныеВычетыФизлиц.Добавить();
			// Свойства
			Движение.Период                 		= ВыборкаПоРаботникиОрганизации.ДатаСобытия;
			Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
			// Измерения
			Движение.ФизЛицо                		= ВыборкаПоРаботникиОрганизации.ФизЛицо;
			Движение.Организация               		= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
			Движение.Год		               		= ВыборкаПоШапкеДокумента.НалоговыйПериод;
			Движение.КодВычетаИмущественный         = Справочники.ВычетыНДФЛ.Код312;
			// Ресурсы
			Движение.Размер							= ВыборкаПоРаботникиОрганизации.ПроцентыПоКредитам; 

		КонецЕсли;
		
		Если ВыборкаПоРаботникиОрганизации.ПроцентыПриПерекредитовании <> 0 Тогда
			
			Движение = Движения.НДФЛИмущественныеВычетыФизлиц.Добавить();
			// Свойства
			Движение.Период                 		= ВыборкаПоРаботникиОрганизации.ДатаСобытия;
			Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
			// Измерения
			Движение.ФизЛицо                		= ВыборкаПоРаботникиОрганизации.ФизЛицо;
			Движение.Организация               		= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
			Движение.Год		               		= ВыборкаПоШапкеДокумента.НалоговыйПериод;
			Движение.КодВычетаИмущественный         = Справочники.ВычетыНДФЛ.Код318;
			// Ресурсы
			Движение.Размер							= ВыборкаПоРаботникиОрганизации.ПроцентыПриПерекредитовании; 
			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры // ДобавитьСтрокуВДвиженияПоРегистрамНакопления


////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	
 	//структура, содержащая имена регистров накопления по которым надо проводить документ
	Перем СтруктураПроведенияПоРегистрамНакопления;
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	РезультатЗапросаПоШапке = СформироватьЗапросПоШапке(Режим);

	// Получим реквизиты шапки из запроса
	ВыборкаПоШапкеДокумента = РезультатЗапросаПоШапке.Выбрать();
	Если ВыборкаПоШапкеДокумента.Следующий() Тогда

		//Надо позвать проверку заполнения реквизитов шапки
		ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок);

		// Движения стоит добавлять, если в проведении еще не отказано (отказ = ложь)
		Если НЕ Отказ Тогда

	// получим реквизиты табличной части
	РезультатЗапросаПоРаботники = СформироватьЗапросПоРаботникиОрганизации(Режим);
	ВыборкаПоРаботникиОрганизации = РезультатЗапросаПоРаботники.Выбрать();
	
	Пока ВыборкаПоРаботникиОрганизации.Следующий() Цикл 
		
		// проверим очередную строку табличной части
		ПроверитьЗаполнениеСтрокиРаботникаОрганизации(ВыборкаПоРаботникиОрганизации, Отказ, Заголовок);
		
		// Заполним записи в наборах записей регистров
		ДобавитьСтрокуВДвиженияПоРегистрамНакопления(ВыборкаПоРаботникиОрганизации, ВыборкаПоШапкеДокумента);
		
	КонецЦикла;
	
	КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	КраткийСоставДокумента = ПроцедурыУправленияПерсоналом.ЗаполнитьКраткийСоставДокумента(РаботникиОрганизации,, "Физлицо");
КонецПроцедуры
