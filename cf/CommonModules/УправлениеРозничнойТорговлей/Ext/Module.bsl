﻿// Определяет есть ли в данном документе склад - неавтоматизированная торговая точка,
// для которого надо указывать цену в рознице.
//
// Параметры: 
//  ДокументОбъект     - объект редактируемого документа.
//
// Возвращаемое значение:
//  Ссылка на розничный склад, если нет розничного склада, то Неопределено.
//
Функция ЕстьНеавтоматизированныйРозничныйСкладДокумента(ДокументОбъект) Экспорт

	МетаданныеДокумента = ДокументОбъект.Метаданные();

	Если ОбщегоНазначения.ЕстьРеквизитДокумента("СкладПолучатель", МетаданныеДокумента) Тогда
		Склад = ДокументОбъект.СкладПолучатель;

	ИначеЕсли ОбщегоНазначения.ЕстьРеквизитДокумента("Склад", МетаданныеДокумента) Тогда
		Склад = ДокументОбъект.Склад;

	Иначе
		Возврат Неопределено; // Нет склада, будем считать, что не розничный.

	КонецЕсли;

	Если Склад.ВидСклада = Перечисления.ВидыСкладов.НеавтоматизированнаяТорговаяТочка Тогда
		Возврат Склад;
	Иначе
		Возврат Неопределено; // Нет розничного склада.

	КонецЕсли;

КонецФункции // ЕстьНеавтоматизированныйРозничныйСкладДокумента()
