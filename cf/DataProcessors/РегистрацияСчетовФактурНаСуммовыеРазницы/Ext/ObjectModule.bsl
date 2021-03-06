﻿Перем мВалютаРегламентированногоУчета Экспорт; 

//Пересчет суммы НДС и валютной суммы при изменении суммы регл.
Процедура ПересчетНДСПоСтроке(ТД) Экспорт
	
	ТД.СуммаНДС = 0;
	
	Если ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС20 Тогда
		ТД.СуммаНДС = ТД.Сумма * 20 / 100;
	ИначеЕсли ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС10 Тогда
		ТД.СуммаНДС = ТД.Сумма * 10 / 100;
	ИначеЕсли ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС18 Тогда
		ТД.СуммаНДС = ТД.Сумма * 18 / 100;
	ИначеЕсли ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС20_120 Тогда
		ТД.СуммаНДС = ТД.Сумма * 20 / 120;
	ИначеЕсли ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС10_110 Тогда
		ТД.СуммаНДС = ТД.Сумма * 10 / 110;
	ИначеЕсли ТД.СтавкаНДС = Перечисления.СтавкиНДС.НДС18_118 Тогда
		ТД.СуммаНДС = ТД.Сумма * 18 / 118;
	КонецЕсли;
	
КонецПроцедуры

// Процедура вызывается при нажатии на кнопку "Заполнить" в диалоге формы
// Реализует алгоритм автоматического заполнения документа.
//
Процедура ЗаполнитьДокумент(ОшибкаЗаполнения = Ложь, Сообщать = Истина, СтрокаСообщения = "") Экспорт
	
	ТаблицаРезультатов = Список.ВыгрузитьКолонки();
	
	ЗаполнитьСтрокиДокумента(ТаблицаРезультатов);
	
	Список.Загрузить(ТаблицаРезультатов);
	
	Список.Сортировать("Дата Возр");
	
	Если Не (Список.Количество() > 0) Тогда
		ОшибкаЗаполнения = Истина;
		СтрокаСообщения = СтрокаСообщения+Символы.ПС+" - суммовые разницы к отражению отдельными счетами-фактурами не обнаружены";
	КонецЕсли;
	
	Если ОшибкаЗаполнения Тогда
		Если Сообщать Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Регистрация отдельных счетов-фактур на суммовые разницы не требуется:"+СтрокаСообщения);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьДокумент()

Процедура ЗаполнитьСтрокиДокумента(ТаблицаРезультатов) Экспорт
	
	УпрощенныйУчетНДС = УчетНДС.ПолучитьУПУпрощенныйУчетНДС(Организация, КонецПериода);
	
	Если УпрощенныйУчетНДС Тогда
		// При упрощенном учете суммовые разницы не учитываются
	Иначе	
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	НДСНачисленныйОбороты.Покупатель КАК Контрагент,
			|	НДСНачисленныйОбороты.СчетФактура КАК ДокументОснование,
			|	НДСНачисленныйОбороты.СтавкаНДС КАК СтавкаНДС,
			|	НДСНачисленныйОбороты.СчетФактура.Дата КАК Дата,
			|	НДСНачисленныйОбороты.СуммаБезНДСПриход + НДСНачисленныйОбороты.НДСПриход КАК Сумма,
			|	НДСНачисленныйОбороты.НДСПриход КАК СуммаНДС
			|ИЗ
			|	РегистрНакопления.НДСНачисленный.Обороты(
			|			&НачалоПериода,
			|			&КонецПериода,
			|			Период,
			|			Организация = &Организация
			|				И ВидЦенности = ЗНАЧЕНИЕ(Перечисление.ВидыЦенностей.СуммыСвязанныеСРасчетамиПоОплате)
			|				И ВидНачисления = ЗНАЧЕНИЕ(Перечисление.НДСВидНачисления.НДСНачисленКУплате)) КАК НДСНачисленныйОбороты
			|ГДЕ
			|	НДСНачисленныйОбороты.СуммаБезНДСПриход + НДСНачисленныйОбороты.НДСПриход <> 0";
		
		Запрос.УстановитьПараметр("ПустаяДата",		'00010101');
		Запрос.УстановитьПараметр("Организация",	Организация);
		Запрос.УстановитьПараметр("НачалоПериода",	Новый граница (НачалоПериода, ВидГраницы.Включая));
		Запрос.УстановитьПараметр("КонецПериода",	Новый Граница(КонецДня(КонецПериода), ВидГраницы.Включая));
		
		ТаблицаРезультатов = Запрос.Выполнить().Выгрузить();
	
	КонецЕсли; 
	
	// Определяем счет-фактуру, соответствующий строке (выписанный ранее)
	Если ТаблицаРезультатов.Количество()>0 Тогда
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	СчетФактураВыданный.Ссылка КАК СчетФактура,
			|	СчетФактураВыданный.СтавкаНДС,
			|	СчетФактураВыданный.ДокументОснование
			|ИЗ
			|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
			|ГДЕ
			|	СчетФактураВыданный.ДокументОснование В(&ДокументыОснования)
			|	И СчетФактураВыданный.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.НДСВидСчетаФактуры.НаСуммовуюРазницу)";
		
		Запрос.УстановитьПараметр("ДокументыОснования", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(ТаблицаРезультатов.ВыгрузитьКолонку("ДокументОснование"), Истина));
		
		СФПоДокументам = Запрос.Выполнить().Выгрузить();
		
		Если СФПоДокументам.Количество()>0 Тогда
			
			СФПоДокументам.Колонки.Добавить("Использован",Новый ОписаниеТипов("Булево"));
			ТаблицаРезультатов.Колонки.Добавить("СчетФактура");
			
			СтруктураОтбора = Новый Структура("ДокументОснование, СтавкаНДС");
			СтруктураОтбора.Вставить("Использован", Ложь);
			
			Для каждого СтрокаРезультата Из ТаблицаРезультатов Цикл
				ЗаполнитьЗначенияСвойств(СтруктураОтбора,СтрокаРезультата);
				
				СтрокаСФ = СФПоДокументам.НайтиСтроки(СтруктураОтбора);
				
				Если СтрокаСФ.Количество() > 0 Тогда
					СтрокаРезультата.СчетФактура = СтрокаСФ[0].СчетФактура;
					СтрокаСФ[0].Использован = Истина;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура СформироватьСчетаФактуры(НеиспользуемыеСчетаФактуры, ЕстьОшибки = ложь) Экспорт
	
	Список.Сортировать("Дата Возр");
	
	ИспользоватьРанееОбнаруженныеДокументы = (НеиспользуемыеСчетаФактуры.Количество()>0);
	
	ПустаяСсылкаСФ = Новый(Тип("ДокументСсылка.СчетФактураВыданный"));
	Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный");
	
	////////////////////////////////////////////////////////////////////////////
	// Предварительная установка пометки на удаление для СФ, выбранных в таблице
	СписокСФ = ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(Список.ВыгрузитьКолонку("СчетФактура"),Истина);
	Для каждого СчФ Из СписокСФ Цикл
		Если СчФ = ПустаяСсылкаСФ Тогда
			Продолжить;
		Иначе
			СчФ = СчФ.Ссылка.ПолучитьОбъект();
			СчФ.УстановитьПометкуУдаления(Истина);
		КонецЕсли; 
	КонецЦикла; 
	// Предварительная установка пометки на удаление для СФ, выбранных в таблице
	////////////////////////////////////////////////////////////////////////////
	
	Для каждого СтрокаТП Из Список Цикл
		
		ОшибкаФормирования = Ложь;
		
		// Создать/использовать Счет-фактуру
		Если не СтрокаТП.СчетФактура = ПустаяСсылкаСФ Тогда
			СчФ = СтрокаТП.СчетФактура.ПолучитьОбъект();
		ИначеЕсли ИспользоватьРанееОбнаруженныеДокументы тогда
			СчФ = НеиспользуемыеСчетаФактуры.Найти(Ложь,"Использован");
			Если СчФ = Неопределено Тогда
				ИспользоватьРанееОбнаруженныеДокументы = Ложь;
				СчФ  = Документы.СчетФактураВыданный.СоздатьДокумент();
				СчФ.Ответственный = Ответственный;
			Иначе
				СчФ.Использован = Истина;
				СчФ = СчФ.Ссылка.ПолучитьОбъект();
			КонецЕсли; 
		Иначе
			СчФ = Документы.СчетФактураВыданный.СоздатьДокумент();
			СчФ.Ответственный = Ответственный;
		КонецЕсли; 
		
		ЗаполнитьЗначенияСвойств(СчФ,СтрокаТП);
		СчФ.Организация = Организация;
		СчФ.ВидСчетаФактуры = Перечисления.НДСВидСчетаФактуры.НаСуммовуюРазницу;
		СчФ.Под0			= Ложь;
		СчФ.СформированПриВводеНачальныхОстатковНДС = Ложь;
		
		СчФ.ДокументыОснования.Очистить();
		СчФ.ДокументыОснования.Добавить().ДокументОснование = СтрокаТП.ДокументОснование;
		
		СчФ.ВалютаДокумента = мВалютаРегламентированногоУчета;
		СчФ.СуммаДокумента	= СтрокаТП.Сумма;
		СчФ.ДоговорКонтрагента = Неопределено;
		
		СчФ.ПометкаУдаления = Ложь;
		
		СообщениеОбОшибке = СчФ.ПроверитьВозможностьЗаписиСФ(ОшибкаФормирования);
		Если ОшибкаФормирования Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Строка "+Строка(СтрокаТП.НомерСтроки)+", не выписан счет-фактура на суммовую разницу."+Символы.ПС+СообщениеОбОшибке);
			СтрокаТП.СФсформирован = ложь;
			СтрокаТП.СчетФактура = Неопределено;
			ЕстьОшибки = Истина;
			Продолжить;
		КонецЕсли; 
		
		СчФ.УстановитьВремя();
		
		ТипОснования = ТипЗнч(СтрокаТП.ДокументОснование);
		
		Если ТипОснования = Тип("ДокументСсылка.ПоступлениеНаРасчетныйСчет") Тогда
			СчФ.НомерПлатежноРасчетногоДокумента = СчФ.ДокументОснование.НомерВходящегоДокумента;
			СчФ.ДатаПлатежноРасчетногоДокумента =  СчФ.ДокументОснование.ДатаВходящегоДокумента;
			
		ИначеЕсли ТипОснования = Тип("ДокументСсылка.ПриходныйКассовыйОрдер") Тогда
			СчФ.НомерПлатежноРасчетногоДокумента = ОбщегоНазначения.ПолучитьНомерНаПечать(СчФ.ДокументОснование);
			СчФ.ДатаПлатежноРасчетногоДокумента =  СчФ.ДокументОснование.Дата;
		Иначе
			СчФ.НомерПлатежноРасчетногоДокумента = "";
			СчФ.ДатаПлатежноРасчетногоДокумента =  Неопределено;
		КонецЕсли;
		
		СТрокаПРД = СчФ.ДатаНомерДокументовОплаты.Добавить();
		СтрокаПРД.ДатаПлатежноРасчетногоДокумента	= СчФ.ДатаПлатежноРасчетногоДокумента;
		СтрокаПРД.НомерПлатежноРасчетногоДокумента	= СчФ.НомерПлатежноРасчетногоДокумента;
		
		Попытка
			СчФ.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
			Сообщить("Выписан счет-фактура на суммовую разницу № " + СчФ.Номер + " от " + СчФ.Дата);
			СтрокаТП.СФсформирован = истина;
			СтрокаТП.СчетФактура = СчФ.Ссылка;
		Исключение
			ОбщегоНазначения.СообщитьОбОшибке("Не выписан счет-фактура на суммовую разницу по строке "+Строка(СтрокаТП.НомерСтроки));
			СтрокаТП.СФсформирован = ложь;
			СтрокаТП.СчетФактура = Неопределено;
			ЕстьОшибки = Истина;
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ОпределитьНаличиеНеиспользуемыхСчетовФактурЗаПериод() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СчетФактураВыданный.Ссылка,
	|	СчетФактураВыданный.ПометкаУдаления
	|ИЗ
	|	Документ.СчетФактураВыданный КАК СчетФактураВыданный
	|ГДЕ
	|	СчетФактураВыданный.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.НДСВидСчетаФактуры.НаСуммовуюРазницу)
	|	И СчетФактураВыданный.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И СчетФактураВыданный.Организация = &Организация
	|	И (НЕ СчетФактураВыданный.Ссылка В (&СФдляОбновления))
	|	И (НЕ СчетФактураВыданный.СформированПриВводеНачальныхОстатковНДС)
	|
	|УПОРЯДОЧИТЬ ПО
	|	СчетФактураВыданный.Дата,
	|	СчетФактураВыданный.Номер";

	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода", КонецДня(КонецПериода));
	Запрос.УстановитьПараметр("СФдляОбновления", ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(Список.ВыгрузитьКолонку("СчетФактура"),Истина));

	Результат = Запрос.Выполнить().Выгрузить();
	Результат.Колонки.Добавить("Использован", Новый ОписаниеТипов("Булево"));
	
	Возврат Результат;

КонецФункции // ОпределитьНаличиеНеиспользуемыхСчетовФактурЗаПериод()

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
