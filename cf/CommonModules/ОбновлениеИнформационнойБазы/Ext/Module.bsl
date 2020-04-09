﻿///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБНОВЛЕНИЯ ИБ 

// Процедура проверяет, есть ли необходимость выполнять обновление информационной базы.
// Если необходимо - выполняется обновление.
// Если обновление не удалось выполнить, то
// - предлагает завершить работу системы (в режиме клиента);
// - выбрасывает исключение с описанием ошибки (в режиме внешнего соединения).
//
// Вызывается в режиме клиента или внешнего соединения.
//
// Параметры:
//  Нет.
//
Процедура ВыполнитьОбновлениеИнформационнойБазы() Экспорт
	
	// Проверка легальности получения обновления.
	Если НЕ ПроверитьЛегальностьПолученияОбновления(Константы.НомерВерсииКонфигурации.Получить()) Тогда
		Возврат;	
	КонецЕсли;
	
	// Проверка необходимости обновления информационной базы.
	ПервыйЗапуск = (Константы.НомерВерсииКонфигурации.Получить()="");
	
	Если НЕ ПустаяСтрока(Метаданные.Версия) и   Константы.НомерВерсииКонфигурации.Получить() <> Метаданные.Версия Тогда
		//первый запуск или обновление
	Иначе
		Возврат;
	КонецЕсли;

	// Проверка наличия прав для обновления информационной базы.
	Если НЕ ПравоДоступа("МонопольныйРежим" , Метаданные) 
	 ИЛИ НЕ ПравоДоступа("Использование"    , Метаданные.Обработки.ОбновлениеИнформационнойБазы) 
	 ИЛИ НЕ ПравоДоступа("Администрирование", Метаданные) Тогда

		#Если Клиент Тогда
		Предупреждение("Недостаточно прав для выполнения обновления. Работа системы будет завершена.");
		глЗначениеПеременнойУстановить("глЗапрашиватьПодтверждениеПриЗакрытии", Ложь);
		ЗавершитьРаботуСистемы();
		#КонецЕсли
		Возврат;

	КонецЕсли;

	БазоваяПоставка = (Найти(ВРег(Метаданные.Имя), "БАЗОВАЯ") > 0);
	
	// Установка монопольного режима для обновления информационной базы.
	Если НЕ БазоваяПоставка Тогда
	
		Попытка
			УстановитьМонопольныйРежим(Истина);

		Исключение
			Сообщить(ОписаниеОшибки(), СтатусСообщения.ОченьВажное);
			#Если Клиент Тогда
			Предупреждение("Не удалось установить монопольный режим. Работа системы будет завершена.");
			глЗначениеПеременнойУстановить("глЗапрашиватьПодтверждениеПриЗакрытии", Ложь);
			ЗавершитьРаботуСистемы();
			#КонецЕсли
			Возврат;

		КонецПопытки;
	
	КонецЕсли; 

	// Обновление информационной базы.
	Обработки.ОбновлениеИнформационнойБазы.Создать().ВыполнитьОбновление();

	// Отключение монопольного режима.
	Если НЕ БазоваяПоставка Тогда
		УстановитьМонопольныйРежим(Ложь);
	КонецЕсли; 

	// Проверка выполнения обновления информационной базы.
	Если Константы.НомерВерсииКонфигурации.Получить() <> Метаданные.Версия Тогда

		Действие = ?(ПервыйЗапуск, "начальное заполнение", "обновление");
		
		Сообщить("Не выполнено " + Действие + " информационной базы .", СтатусСообщения.Важное);

		#Если Клиент Тогда
		Текст = "Не выполнено " + Действие + " информационной базы! Завершить работу системы?";
		Ответ = Вопрос(Текст, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да, );

		Если Ответ = КодВозвратаДиалога.Да Тогда
			глЗначениеПеременнойУстановить("глЗапрашиватьПодтверждениеПриЗакрытии", Ложь);
			ЗавершитьРаботуСистемы();
		КонецЕсли;
		#КонецЕсли
		
	ИначеЕсли НЕ ПервыйЗапуск Тогда
		Сообщить("Обновление информационной базы выполнено успешно.", СтатусСообщения.Информация);

	КонецЕсли;
	
КонецПроцедуры

// Проверить легальность получения обновления.
//
// Параметры
//  ТекущаяВерсияИБ  - Строка - номер версии ИБ.
//
// Возвращаемое значение:
//   Булево   - Истина, если проверка завершилась успешно.
//
Функция ПроверитьЛегальностьПолученияОбновления(Знач ТекущаяВерсияИБ)

#Если Клиент Тогда
	Если ЭтоБазоваяВерсияКонфигурации()	Тогда
		Возврат Истина;
	КонецЕсли;
		
	Если ТекущаяВерсияИБ <> Метаданные.Версия И ТекущаяВерсияИБ <> "" Тогда
		Форма = Обработки.ЛегальностьПолученияОбновлений.ПолучитьФорму();
		Форма.ПоказыватьПредупреждениеОПерезапуске = Истина;
		Результат = Форма.ОткрытьМодально();
		Если Результат <> Истина Тогда
			ЗавершитьРаботуСистемы(Ложь);
			Возврат Ложь;
		КонецЕсли; 
	КонецЕсли;
#КонецЕсли
	Возврат Истина;

КонецФункции 
 
Функция ЭтоБазоваяВерсияКонфигурации()
	
	Возврат Найти(ВРег(Метаданные.Имя), "БАЗОВАЯ") > 0;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОТОКОЛИРОВАНИЕ ХОДА ОБНОВЛЕНИЯ

Функция СобытиеЖурналаРегистрации() Экспорт
	
	Возврат НСтр("ru = 'Обновление информационной базы'");
	
КонецФункции