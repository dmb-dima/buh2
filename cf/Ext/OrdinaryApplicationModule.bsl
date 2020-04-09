﻿Перем глОбщиеЗначения Экспорт;

Перем глСерверТО Экспорт;
//// Прочие переменные, используемые только в процедурах данного модуля.

// Адрес сервера, на котором хранятся данные для интернет-поддержки.
Перем АдресРесурсовОбозревателя Экспорт;

// Быстрый доступ к бухгалтерским итогам 
Перем БИ Экспорт;

Перем ПараметрыВнешнихРегламентированныхОтчетов Экспорт;
Перем КонтекстЭДО Экспорт;
Перем КонтекстОнлайнСервисовРегламентированнойОтчетности Экспорт;

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ГЛОБАЛЬНОГО КОНТЕКСТА

// Процедура - обработчик события "Перед завершением работы системы".
//
Процедура ПередЗавершениемРаботыСистемы(Отказ)
	
	ЗапрашиватьПодтверждение = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ЗапрашиватьПодтверждениеПриЗакрытии");
		
	Если глЗначениеПеременной("глЗапрашиватьПодтверждениеПриЗакрытии") <> Ложь Тогда
		Если ЗапрашиватьПодтверждение Тогда
			Ответ = Вопрос("Завершить работу с программой?", РежимДиалогаВопрос.ДаНет);
			Отказ = (Ответ = КодВозвратаДиалога.Нет);
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ Отказ Тогда
		
		// отдельно получаем настройки для которых нужно выполнить обмен при выходе из программы
		ПроцедурыОбменаДанными.ВыполнитьОбменПриЗавершенииРаботыПрограммы(глЗначениеПеременной("глОбработкаАвтоОбменДанными"));
			
	КонецЕсли;

КонецПроцедуры

// Процедура - обработчик события "При завершением работы системы".
//
Процедура ПриЗавершенииРаботыСистемы()

	// Показ финальной дополнительной информации
	Форма = Обработки.ДополнительнаяИнформация.Создать();
	Форма.ВыполнитьДействие();
	//
	
КонецПроцедуры

// Процедура - обработчик события "Перед началом работы системы".
//
Процедура ПередНачаломРаботыСистемы(Отказ)
	
	УправлениеПользователями.ПроверитьВозможностьРаботыПользователя(Отказ);	
	
КонецПроцедуры

// Процедура - обработчик события "При начале работы системы".
//
Процедура ПриНачалеРаботыСистемы()
	
	КонтрольВерсииПлатформы.ПроверитьВерсиюПлатформы(); 

	ПервыйЗапуск = (Константы.НомерВерсииКонфигурации.Получить()="");
	
	ПользовательОпределен = Ложь;
	ОписаниеОшибкиОпределенияПользователя = "";
	Если Не ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь) Тогда
		Если УправлениеПользователями.ОпределитьТекущегоПользователя(ОписаниеОшибкиОпределенияПользователя) Тогда
			ПользовательОпределен = ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь);
		КонецЕсли;
	Иначе
		ПользовательОпределен = Истина;
	КонецЕсли;
	
	Если Не ПользовательОпределен Тогда
		Если ПустаяСтрока(ОписаниеОшибкиОпределенияПользователя) Тогда
			ОписаниеОшибкиОпределенияПользователя = "Ошибка идентификации пользователя. Обратитесь к администратору";
		КонецЕсли;
		Предупреждение(ОписаниеОшибкиОпределенияПользователя);
		ЗавершитьРаботуСистемы(Ложь);
		Возврат;
	Иначе
		
		//Заменим интерфейс УСН8
		#Если Клиент Тогда
		Если Константы.ПрименяемыеСистемыНалогообложения.Получить() = Перечисления.ПрименяемыеСистемыНалогообложения.УпрощеннаяСистемаНалогообложения Тогда
			ГлавныйИнтерфейс.Полный.Видимость 			= (Ложь);
			ГлавныйИнтерфейс.Бухгалтерский.Видимость 	= (Ложь);
			ГлавныйИнтерфейс.УСН.Видимость 				= (Истина);
		// {УчетДоходовИРасходовИП
			ГлавныйИнтерфейс.НДФЛИП.Видимость 			= (Ложь);
		ИначеЕсли Константы.ПрименяемыеСистемыНалогообложения.Получить() = Перечисления.ПрименяемыеСистемыНалогообложения.НДФЛИндивидуальногоПредпринимателя Тогда
			ГлавныйИнтерфейс.Полный.Видимость 			= (Ложь);
			ГлавныйИнтерфейс.Бухгалтерский.Видимость 	= (Ложь);
			ГлавныйИнтерфейс.УСН.Видимость 				= (Ложь);
			ГлавныйИнтерфейс.НДФЛИП.Видимость 			= (Истина);
		// }УчетДоходовИРасходовИП
		КонецЕсли;
		ГлавныйИнтерфейс.ДемонстрационнаяБаза.Видимость = ОбщегоНазначения.ЭтоДемонстрационнаяБаза();
		#КонецЕсли
		
		
		// Если пользователю доступна только одна организация, то установим ее в качестве основной
		Запрос = Новый Запрос();
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Организации.Наименование,
		|	Организации.Ссылка
		|ИЗ
		|	Справочник.Организации КАК Организации";
		Выборка = Запрос.Выполнить().Выбрать();
		
		КоличествоЗаписейВВыборке = Выборка.Количество();
		
		Если КоличествоЗаписейВВыборке = 1 Тогда
			
			Выборка.Следующий();
			
			УправлениеПользователями.УстановитьЗначениеПоУмолчанию(
				ПараметрыСеанса.ТекущийПользователь, 
				"ОсновнаяОрганизация", 
				Выборка.Ссылка);
		ИначеЕсли КоличествоЗаписейВВыборке = 0 Тогда
			
			Выборка.Следующий();
			
			УправлениеПользователями.УстановитьЗначениеПоУмолчанию(
				ПараметрыСеанса.ТекущийПользователь, 
				"ОсновнаяОрганизация", 
				Неопределено);
		КонецЕсли;			
	КонецЕсли;
	
	ЗаголовокСистемы = Константы.ЗаголовокСистемы.Получить();
	
	Если Пустаястрока(ЗаголовокСистемы) Тогда
		Если ЗначениеЗаполнено(глЗначениеПеременной("ОсновнаяОрганизация")) Тогда
			УстановитьЗаголовокСистемы(Строка(глЗначениеПеременной("ОсновнаяОрганизация")));
		КонецЕсли;
	Иначе
		УстановитьЗаголовокСистемы(ЗаголовокСистемы);
	КонецЕсли; 

	// Открытие Панели функций
	Если (НЕ ПервыйЗапуск) Тогда
		ПроверитьЗапускСтартовогоПомощникаИПанелиФункций();		
	КонецЕсли;
	
	БИ = Обработки.БухгалтерскиеИтоги.Создать();
	
	// Установить начальное значение ТипДетализацииСтандартныхОтчетов
	Если УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ТипДетализацииСтандартныхОтчетов") = Перечисления.ТипДетализацииСтандартныхОтчетов.ПустаяСсылка() Тогда
		УправлениеПользователями.УстановитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ТипДетализацииСтандартныхОтчетов", Перечисления.ТипДетализацииСтандартныхОтчетов.Элементы);
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ВыполнитьОбновлениеИнформационнойБазы();
	
	// {КОРП
		//ГотовностьИнформационнойБазыКРаботе(ПервыйЗапуск);	
	// }КОРП
	
	// Выполнить проверку разницы времени с сервером приложения
	Если НЕ ПроверкаРазницыВремениКлиент.ВыполнитьПроверку() Тогда
		Возврат;	
	КонецЕсли;

	// отработка параметров запуска системы
	Если ОбработатьПараметрыЗапуска(ПараметрЗапуска) Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеСоединениямиИБ.УстановитьКонтрольРежимаЗавершенияРаботыПользователей();
    
	// Форма помощника обновления конфигурации выводится поверх остальных окон.
	Если РольДоступна(Метаданные.Роли.ПолныеПрава) Тогда
		ОбработкаОбновлениеКонфигурации = Обработки.ОбновлениеКонфигурации.Создать();
		ОбработкаОбновлениеКонфигурации.ПроверитьНаличиеОбновлений();
	КонецЕсли;

	ЭтоФайловаяИБ = ОпределитьЭтаИнформационнаяБазаФайловая();
		
	Если ЭтоФайловаяИБ Тогда
					
		ПользовательДляВыполненияРеглЗаданий = Константы.ПользовательДляВыполненияРегламентныхЗаданийВФайловомВарианте.Получить();
		
		Если глЗначениеПеременной("глТекущийПользователь") = ПользовательДляВыполненияРеглЗаданий Тогда
			
			// с интервалом секунд вызываем процедуру работы с регламентными заданиями
			ПоддержкаРегламентныхЗаданиеДляФайловойВерсии();
			
			ИнтервалДляОпроса = Константы.ИнтервалДляОпросаРегламентныхЗаданийВФайловомВарианте.Получить();
			
			Если ИнтервалДляОпроса = Неопределено
				ИЛИ ИнтервалДляОпроса = 0 Тогда
				
				ИнтервалДляОпроса = 60;	
				
			КонецЕсли;
			
			ПодключитьОбработчикОжидания("ПоддержкаРегламентныхЗаданиеДляФайловойВерсии", ИнтервалДляОпроса);
			
		КонецЕсли;
		
	КонецЕсли;
	
	// защищенный документооборот с ФНС
	Если ИнициализироватьКонтекстДокументооборотаСНалоговымиОрганами() Тогда
		ПодключитьОбработчикАвтообменаСНалоговымиОрганами();
	КонецЕсли;
	
	// автообмен данными
	Если глЗначениеПеременной("глОбработкаАвтоОбменДанными") <> Неопределено Тогда
		
		// подключим обработчик обменов данными
		ПодключитьОбработчикОжидания("ПроверкаОбменаДанными", глЗначениеПеременной("глКоличествоСекундОпросаОбмена"));
			
	КонецЕсли;
	
	// Календарь бухгалтера. Регламентированная отчетность.
	ПроверитьНапоминанияКалендарьБухгалтераСобытия();
	
	// Начнем проверку динамического обновления конфигурации
	НачатьПроверкуДинамическогоОбновленияИБ();
	
	// Загрузить курсы валют
	Если УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "АвтозагрузкаКурсовВалютПриНачалеРаботы") Тогда
		
		// Проверить если необходимо загрузить курсы валют
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ МАКСИМУМ(Период) КАК МаксПериод ИЗ РегистрСведений.КурсыВалют.СрезПоследних()";
		РезультатЗапроса = Запрос.Выполнить();
		Выборка = РезультатЗапроса.Выбрать();
		НачалоПредыдущегоМесяца = ДобавитьМесяц(НачалоМесяца(ТекущаяДата()), -1);
		Если Выборка.Следующий() И ЗначениеЗаполнено(Выборка.МаксПериод) Тогда
			НачДата = Макс(КонецДня(Выборка.МаксПериод) + 1, НачалоПредыдущегоМесяца);
		Иначе
			НачДата = НачалоПредыдущегоМесяца;
		КонецЕсли;
		
		Если НачДата <= НачалоДня(ТекущаяДата()) Тогда
			
			КурсыВалютРБК = Обработки.КурсыВалютРБК.Создать();
			КурсыВалютРБК.НачДата = НачДата;
			КурсыВалютРБК.КонДата = КонецМесяца(ТекущаяДата());
			КурсыВалютРБК.ОбновитьСписокВалют();
			КурсыВалютРБК.ЗагрузитьКурсыВалют();
			
		КонецЕсли;
			
	КонецЕсли;
	
	Если ЭтоФайловаяИБ Тогда
		ПроверитьИзменитьПериодРассчитаныхИтогов(ПервыйЗапуск);
	КонецЕсли;
	
КонецПроцедуры // ПриНачалеРаботыСистемы()

// Обработать параметр запуска программы.
// Реализация функции может быть расширена для обработки новых параметров.
//
// Параметры
//  ПараметрЗапуска  – Строка – параметр запуска, переданный в конфигурацию 
//								с помощью ключа командной строки /C.
//
// Возвращаемое значение:
//   Булево   – Истина, если необходимо прервать выполнение процедуры ПриНачалеРаботыСистемы.
//
Функция ОбработатьПараметрыЗапуска(Знач ПараметрЗапуска)

	// есть ли параметры запуска
	Если ПустаяСтрока(ПараметрЗапуска) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// Параметр может состоять из частей, разделенных символом ";".
	// Первая часть - главное значение параметра запуска. 
	// Наличие дополнительных частей определяется логикой обработки главного параметра.
	ПараметрыЗапуска = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ПараметрЗапуска,";");
	ЗначениеПараметраЗапуска = Врег(ПараметрыЗапуска[0]);
	
	Результат = УправлениеСоединениямиИБ.ОбработатьПараметрыЗапуска(ЗначениеПараметраЗапуска, ПараметрыЗапуска);
	Возврат Результат;

КонецФункции 

///////////////////////////////////////////////////////////////////////////////
// Проверка границы рассчитанных итогов

Процедура ПроверитьИзменитьПериодРассчитаныхИтогов(ПервыйЗапуск)
	
	ТекущаяДата = ТекущаяДата();
	КонтрольнаяДата = ДобавитьМесяц(НачалоМесяца(ТекущаяДата)-1,-1);
	ДатаИтогов = НачалоМесяца(ТекущаяДата)-1;
	БазоваяПоставка = (Найти(ВРег(Метаданные.Имя), "БАЗОВАЯ") > 0);
	ПериодРассчитанныхИтогов = РегистрыБухгалтерии.Хозрасчетный.ПолучитьПериодРассчитанныхИтогов();
	
	Если ПервыйЗапуск Тогда
		
		ИзменитьПериодРассчитанныхИтогов(Истина, ДатаИтогов);
		
	ИначеЕсли БазоваяПоставка Тогда
		
		Если ПериодРассчитанныхИтогов < КонтрольнаяДата Тогда
			ИзменитьПериодРассчитанныхИтогов(Истина, ДатаИтогов);
		ИначеЕсли ПериодРассчитанныхИтогов > ТекущаяДата Тогда
			ИзменитьПериодРассчитанныхИтогов(Ложь, ДатаИтогов);
		КонецЕсли;
		
	Иначе
		
		#Если Клиент Тогда
			
			Если ПериодРассчитанныхИтогов = '00010101' Тогда 
				ТекстСообщения = "Итоги в информационной базе не рассчитаны."
			Иначе				
				ТекстСообщения = "Итоги в информационной базе рассчитаны по " + Формат(ПериодРассчитанныхИтогов, "ДЛФ=DD"); 
			КонецЕсли;
			
			ТекстСообщения = ТекстСообщения  + "
			|Дата рассчитанных итогов влияет на скорость проведения документов и формирования отчетов.
			|Рекомендуется поддерживать границу рассчитанных итогов на конец предыдущего месяца.";
			
			Если РольДоступна("ПолныеПрава") ИЛИ РольДоступна("ПравоАдминистрирования") Тогда
				
				ТекстВопроса = ТекстСообщения  + "
				|Установка новой границы рассчитанных итогов может занять некоторое время.
				|
				|Установить границу рассчитанных итогов на " + Формат(ДатаИтогов, "ДЛФ=DD") + "?";
				
				Если ПериодРассчитанныхИтогов < КонтрольнаяДата Тогда
					Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет);
					Если Ответ = КодВозвратаДиалога.Да Тогда
						ИзменитьПериодРассчитанныхИтогов(Истина, ДатаИтогов);
					КонецЕсли;
				ИначеЕсли ПериодРассчитанныхИтогов > ТекущаяДата Тогда
					Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет);
					Если Ответ = КодВозвратаДиалога.Да Тогда
						ИзменитьПериодРассчитанныхИтогов(Ложь, ДатаИтогов);
					КонецЕсли;
				КонецЕсли;
				
			Иначе
				Если ПериодРассчитанныхИтогов < ДобавитьМесяц(КонтрольнаяДата,1) Тогда
					ТекстСообщения = ТекстСообщения + "
					|
					|Для выполнения этой процедуры необходимо обратиться к пользователю, обладающему полными правами.";
					Предупреждение(ТекстСообщения); 
				КонецЕсли;
			КонецЕсли;
		#КонецЕсли
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ИзменитьПериодРассчитанныхИтогов(ИзменитьГраницу, ДатаИтогов)
	
	//Регистр бухгалтерии
	Если ИзменитьГраницу Тогда
		РегистрыБухгалтерии.Хозрасчетный.УстановитьПериодРассчитанныхИтогов(ДатаИтогов);
	Иначе
		РегистрыБухгалтерии.Хозрасчетный.ПересчитатьИтоги();
	КонецЕсли;
	
	//Регистры накопления
	ОграничениеПоВидуРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки;
	Для Каждого МенеджерРегистра ИЗ РегистрыНакопления Цикл
		МетаданныеРегистра = Метаданные.НайтиПоТипу(ТипЗнч(МенеджерРегистра));
		
		Если  МетаданныеРегистра.ВидРегистра <> ОграничениеПоВидуРегистра Тогда
			Продолжить;
		КонецЕсли;
		
		Если ИзменитьГраницу Тогда
			МенеджерРегистра.УстановитьПериодРассчитанныхИтогов(ДатаИтогов);
		Иначе
			МенеджерРегистра.ПересчитатьИтоги();
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// {КОРП

///////////////////////////////////////////////////////////////////////////////
// Проверка перехода с версии ПРОФ на КОРП версию

//Процедура ГотовностьИнформационнойБазыКРаботе(ПервыйЗапуск)
//	
//	Если ПервыйЗапуск Тогда 
//		Возврат;
//	КонецЕсли;
//	
//	Если Константы.ГотовностьИнформационнойБазыКРаботе.Получить() Тогда
//		Возврат;
//	КонецЕсли;
//	
//	#Если Клиент Тогда
//		Обработки.ПодготовкаИнформационнойБазы1СБухгалтерииКОРП.ПолучитьФорму().Открыть();
//	#Иначе
//		ЗавершитьРаботуСистемы(Ложь);
//	#КонецЕсли 	
//		
//КонецПроцедуры

// }КОРП

///////////////////////////////////////////////////////////////////////////////
// СЕРВИСНЫЕ ПРОЦЕДУРЫ

Процедура ПроверитьЗапускСтартовогоПомощникаИПанелиФункций()
	
	СПОткрыт = Ложь;
	
	Если РольДоступна("ПолныеПрава") Тогда
		
		КоличествоОрганизаций = 0;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(Организации.Ссылка) КАК КоличествоОрганизаций
		|ИЗ
		|	Справочник.Организации КАК Организации";
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			КоличествоОрганизаций = Выборка.КоличествоОрганизаций;
		КонецЕсли;

		Если КоличествоОрганизаций = 0 Тогда
			ПервыйЗапуск = Истина;
		ИначеЕсли КоличествоОрганизаций = 1 Тогда
			
			Запрос.Текст =
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Организации.Ссылка
			|ИЗ
			|	Справочник.Организации КАК Организации
			|ГДЕ
			|	(Организации.Наименование = ""Наша организация""
			|	ИЛИ Организации.Наименование = ""Предприниматель"")
			|	И (ВЫРАЗИТЬ(Организации.НаименованиеПолное КАК СТРОКА (100)) = ""Наша организация""
			|	ИЛИ ВЫРАЗИТЬ(Организации.НаименованиеПолное КАК СТРОКА (100)) = ""Предприниматель""
			|	ИЛИ ВЫРАЗИТЬ(Организации.НаименованиеПолное КАК СТРОКА (100)) = """")";
			РезультатЗапроса = Запрос.Выполнить();
			
			ПервыйЗапуск = НЕ РезультатЗапроса.Пустой();
		Иначе
			ПервыйЗапуск = Ложь;
		КонецЕсли;
		
		Если ПервыйЗапуск Тогда
					
			ФормаСтартовогоОкна = ПолучитьОбщуюФорму("НачалоРаботы");
			ФормаСтартовогоОкна.Открыть();
			
			СПОткрыт = Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ СПОткрыт Тогда
		
		// Заполнить чеклист помощника начала работы.
		ХранилищеЧеклиста = Константы.ГотовностьПрограммыКРаботе.Получить();
		Чеклист = ХранилищеЧеклиста.Получить();
		Если Чеклист = Неопределено 
			Или ТипЗнч(Чеклист) <> Тип("Соответствие") Тогда
			Чеклист = Новый Соответствие;
			Чеклист["Организации2"]                           = Истина;
			Чеклист["НастройкаПараметровУчета2"]              = Истина;
			Чеклист["УчетнаяПолитикаОрганизаций2"]            = Истина;
			Чеклист["ПодразделенияОрганизаций1"]              = Истина;
			Чеклист["ОтчетОТекущихНастройках"]                = Истина;
			Чеклист["СтатьиЗатрат"]                           = Истина;
			Чеклист["Номенклатура2"]                          = Истина;
			Чеклист["НоменклатурныеГруппы"]                   = Истина;
			Чеклист["Склады1"]                                = Истина;
			Чеклист["Контрагенты4"]                           = Истина;
			Чеклист["СпособыОтраженияРасходовПоАмортизации3"] = Истина;
			Чеклист["ОсновныеСредства1"]                      = Истина;
			Чеклист["СпособыОтраженияЗарплатыВРеглУчете1"]    = Истина;
			Чеклист["СотрудникиОрганизаций"]                  = Истина;
			Чеклист["ВводНачальныхОстатков2"]                 = Истина;
			ХранилищеЧеклиста = Новый ХранилищеЗначения(Чеклист);
			Константы.ГотовностьПрограммыКРаботе.Установить(ХранилищеЧеклиста);
		КонецЕсли;
		
		// Управление видимостью закладки "Начало работы".
		ДеревоЗакладок = ВосстановитьЗначение("ПанельФункций_ВидимостьЗакладок");
		Если ДеревоЗакладок = Неопределено Тогда
			ДеревоЗакладок = Новый ДеревоЗначений;
			ДеревоЗакладок.Колонки.Добавить("Закладка");
			ДеревоЗакладок.Колонки.Добавить("ИмяЗакладки");
			ДеревоЗакладок.Колонки.Добавить("Видимость");
		КонецЕсли;
		
		Если ДеревоЗакладок.Строки.Найти("НачалоРаботы", "ИмяЗакладки") = Неопределено Тогда 
			НоваяСтрока = ДеревоЗакладок.Строки.Добавить();
			НоваяСтрока.Закладка    = "Начало работы";
			НоваяСтрока.ИмяЗакладки = "НачалоРаботы";
			НоваяСтрока.Видимость   = Ложь;
			СохранитьЗначение("ПанельФункций_ВидимостьЗакладок", ДеревоЗакладок);
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверка установки флага чеклиста "Отчет о текущих настройках".
	ХранилищеЧеклиста = Константы.ГотовностьПрограммыКРаботе.Получить();
	Чеклист = ХранилищеЧеклиста.Получить();
	Если Чеклист <> Неопределено
		И ТипЗнч(Чеклист) = Тип("Соответствие") Тогда
		Если Чеклист["СтатьиЗатрат"] <> Неопределено 
			 И Чеклист["ОтчетОТекущихНастройках"] = Неопределено Тогда
			Чеклист["ОтчетОТекущихНастройках"] = Истина;
			ХранилищеЧеклиста = Новый ХранилищеЗначения(Чеклист);
			Константы.ГотовностьПрограммыКРаботе.Установить(ХранилищеЧеклиста);
		КонецЕсли;
	КонецЕсли;
	
	ОткрытьПанельФункций = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОткрыватьПриЗапускеПанельФункций");
	Если НЕ СПОткрыт И ОткрытьПанельФункций Тогда
		// Открытие панели функций
		Обработки.ПанельФункций.ПолучитьФорму().Открыть();
	КонецЕсли;
	
	Если НЕ СПОткрыт И ОбщегоНазначения.ЭтоДемонстрационнаяБаза() Тогда
		// Открытие путеводителя по демонстрационной базе.
		ПоказыватьПутеводительПриОткрытииПрограммы = ВосстановитьЗначение("Путеводитель_ПоказыватьПриОткрытииПрограммы");
		Если ПоказыватьПутеводительПриОткрытииПрограммы <> Ложь Тогда
			ОбщегоНазначения.ОткрытьПутеводительПоДемонстрационнойБазе();
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ СПОткрыт Тогда
		// Открытие дополнительной информации
		Форма = Обработки.ДополнительнаяИнформация.ПолучитьФорму("ФормаРабочийСтол");
		Форма.Открыть();
	КонецЕсли;
	
КонецПроцедуры

// Открывает форму текущего пользователя для изменения его настроек.
//
// Параметры:
//  Нет.
//
Процедура ОткрытьФормуТекущегоПользователя() Экспорт

	Если НЕ ЗначениеЗаполнено(глЗначениеПеременной("глТекущийПользователь")) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не задан текущий пользователь.");

	Иначе
		глЗначениеПеременной("глТекущийПользователь").ПолучитьФорму().Открыть();

	КонецЕсли;

КонецПроцедуры // ОткрытьФормуТекущегоПользователя()

// ПроверитьНапоминанияПользователяКалендарьБухгалтераСобытия
//
Процедура ПроверитьНапоминанияКалендарьБухгалтераСобытия() Экспорт
	РегламентированнаяОтчетность.ПроверитьНапоминанияПользователяКалендарьБухгалтераСобытия(глЗначениеПеременной("глТекущийПользователь"));
КонецПроцедуры // ПроверитьНапоминанияПользователяКалендарьБухгалтераСобытия

// Процедура осуществляет проверку на необходимость обмена данными с заданным интервалом
Процедура ПроверкаОбменаДанными() Экспорт
		
	Если глЗначениеПеременной("глОбработкаАвтоОбменДанными") = Неопределено Тогда
		Возврат;
	КонецЕсли;		
	
	ОтключитьОбработчикОжидания("ПроверкаОбменаДанными");
	
	// проводим обмен данными
	глЗначениеПеременной("глОбработкаАвтоОбменДанными").ПровестиОбменДанными(); 
		
	ПодключитьОбработчикОжидания("ПроверкаОбменаДанными", глЗначениеПеременной("глКоличествоСекундОпросаОбмена"));

КонецПроцедуры


Функция глЗначениеПеременной(Имя) Экспорт
	
	Возврат ОбщегоНазначения.ПолучитьЗначениеПеременной(Имя, глОбщиеЗначения);

КонецФункции

// Процедура установки значения экспортных переменных модуля приложения
//
// Параметры
//  Имя - строка, содержит имя переменной целиком
// 	Значение - значение переменной
//
Процедура глЗначениеПеременнойУстановить(Имя, Значение, ОбновлятьВоВсехКэшах = Ложь) Экспорт
	
	ОбщегоНазначения.УстановитьЗначениеПеременной(Имя, глОбщиеЗначения, Значение, ОбновлятьВоВсехКэшах);
	
КонецПроцедуры


// функция вызова формы редактирования настройки файла обновления конфигурации
Процедура ОткрытьФормуРедактированияНастройкиФайлаОбновления() Экспорт
	
	Если НЕ ПравоДоступа("Чтение", Метаданные.Константы.НастройкаФайлаОбновленияКонфигурации) Тогда
		
		Предупреждение("Нет прав на чтение данных константы ""Настройка файла обновления конфигурации""", 30, "Настройка файла обновления конфигурации");		
		Возврат;
		
	КонецЕсли;

	ФормаРедактирования = ПолучитьОбщуюФорму("НастройкаФайлаОбновленияКонфигурации");
	ФормаРедактирования.СтруктураПараметров = ПроцедурыОбменаДанными.ПолучитьНастройкиДляФайлаОбновленияКонфигурации(); 
	ФормаРедактирования.Открыть();
	
КонецПроцедуры

// Функция возвращает объект для взаимодействия с торговым оборудованием.
//
// Параметры:
//  Нет.
//
// Возвращаемое значение:
//  <ОбработкаОбъект> - Объект для взаимодействия с торговым оборудованием.
//
Функция ПолучитьСерверТО() Экспорт

	Если глСерверТО = Неопределено Тогда
		глСерверТО = Обработки.ТОСервер.Создать();
	КонецЕсли;

	Возврат глСерверТО;

КонецФункции // ПолучитьСерверТО()

Процедура Бухгалтерский15Действие() Экспорт
	// Вставить содержимое обработчика.
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ДОКУМЕНТООБОРОТ С НАЛОГОВЫМИ ОРГАНАМИ
//

Функция ИнициализироватьКонтекстДокументооборотаСНалоговымиОрганами() Экспорт
	
	ЭтоПерваяИтерация = Истина;
	ИнициализироватьКонтекст = Истина;
	Пока ИнициализироватьКонтекст Цикл
	
		ИнициализироватьКонтекст = Ложь;
		
		// если подключена внешняя обработка, то используем ее
		Если ПравоДоступа("Чтение", Метаданные.Константы.ДокументооборотСКонтролирующимиОрганами_ИспользоватьВнешнийМодуль)
		И ПравоДоступа("Чтение", Метаданные.Константы.ДокументооборотСКонтролирующимиОрганами_ВнешнийМодуль) Тогда
			
			// если подключена внешняя обработка, то используем ее
			Если Константы.ДокументооборотСКонтролирующимиОрганами_ИспользоватьВнешнийМодуль.Получить() Тогда
				ВнешниеОбъектыХранилище = Константы.ДокументооборотСКонтролирующимиОрганами_ВнешнийМодуль;
				ДвоичныеДанныеОбработки = ВнешниеОбъектыХранилище.Получить().Получить();
				Если ДвоичныеДанныеОбработки <> Неопределено Тогда
					ИмяФайлаОбработки = ПолучитьИмяВременногоФайла("epf");
					ДвоичныеДанныеОбработки.Записать(ИмяФайлаОбработки);
					Попытка
						КонтекстЭДО = ВнешниеОбработки.Создать(ИмяФайлаОбработки);
					Исключение
						Сообщить("Не удалось загрузить внешний модуль для документооборота с налоговыми органами:
								|" + ИнформацияОбОшибке().Описание + "
								|Будет использован модуль, встроенный в конфигурацию.", СтатусСообщения.Важное);
					КонецПопытки;
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
		// если внешняя не подключена, то используем встроенную
		Если КонтекстЭДО = Неопределено И ПравоДоступа("Использование", Метаданные.Обработки.ДокументооборотСКонтролирующимиОрганами) Тогда
			КонтекстЭДО = Обработки.ДокументооборотСКонтролирующимиОрганами.Создать();
		КонецЕсли;
		
		// обновляем модуль документооборота с ФНС из Интернет при необходимости
		Если ЭтоПерваяИтерация И КонтекстЭДО <> Неопределено Тогда
			Попытка
				МодульОбновлен = КонтекстЭДО.ОбновитьМодульДокументооборотаСФНСПриНеобходимости();
				Если МодульОбновлен Тогда
					ИнициализироватьКонтекст = Истина;
				КонецЕсли;
			Исключение
				Сообщить("Не удалось проверить доступность обновления модуля документооборота с ФНС по причине внутренней ошибки:
						|" + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
			КонецПопытки;
		КонецЕсли;
		
		ЭтоПерваяИтерация = Ложь;
		
	КонецЦикла;
	
	Возврат (КонтекстЭДО <> Неопределено);
	
КонецФункции

Процедура ОбработчикАвтообменаСНалоговымиОрганами() Экспорт
	
	Если КонтекстЭДО <> Неопределено Тогда
		КонтекстЭДО.ОбработчикАвтообмена();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодключитьОбработчикАвтообменаСНалоговымиОрганами()
	
	Если РольДоступна("ПравоНаЗащищенныйДокументооборотСКонтролирующимиОрганами") ИЛИ РольДоступна("ПолныеПрава") Тогда
		Если КонтекстЭДО <> Неопределено Тогда
			Попытка
				КонтекстЭДО.ПодключитьОбработчикАвтообменаСНалоговымиОрганами();
			Исключение
				Сообщить("Не удалось инициализировать обработчик автоматического обмена с контролирующими органами:
								|" + ИнформацияОбОшибке().Описание, СтатусСообщения.Важное);
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

АдресРесурсовОбозревателя = "Accounting";
Если Найти(ВРег(Метаданные.Имя), "БАЗОВАЯ") > 0 Тогда
	АдресРесурсовОбозревателя = АдресРесурсовОбозревателя + "Base";
ИначеЕсли Найти(ВРег(Метаданные.Имя), "КОРП") > 0 Тогда
	АдресРесурсовОбозревателя = АдресРесурсовОбозревателя + "Corp";
КонецЕсли;
