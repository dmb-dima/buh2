﻿// Особенность данной обработки состоит в том, что ее функции и процедуры
// используются как для интерактивного обновления списка отчетов по запросу
// пользователя, так и для первоначального заполнения списка при первом запуске
// конфигурации. Это обусловило набор процедур и функций и последовательность
// их вызовов.


// Выполняет поиск элемента справочника "Регламентированные ртчеты"
// по заданным ключевым параметрам.
//
// Параметры
//  Наименование  – Строка                                    – наименование элемента справочника;
//  Источник      – Строка                                    – значение индексируемого реквизита 
//                 "ИсточникОтчета" элемента спрвочника;
//
//  ЭтоГруппа     – Булево                                    – признак группы справочника;
//  Родитель      – СправочникСсылка.РегламентированныеОтчеты – содержит ссылку на родителя искомого элемента.
//
// Возвращаемое значение:
//   СправочникСсылка.РегламентированныеОтчеты   – ссылка на найденный элемент справочника.
//
Функция ПоискЭлементаПоРеквизитам(Наименование, Источник = "", ЭтоГруппа = Ложь, Родитель = Неопределено)

	РегламОтчеты = Справочники.РегламентированныеОтчеты;

	Если ЭтоГруппа Тогда

		НайденнаяГруппа = РегламОтчеты.НайтиПоНаименованию(Наименование, Истина, Родитель);

		Если НайденнаяГруппа <> РегламОтчеты.ПустаяСсылка() Тогда

			Возврат НайденнаяГруппа;

		КонецЕсли;

	Иначе

		ВыборкаОтчеты = РегламОтчеты.Выбрать(Родитель);
		Пока ВыборкаОтчеты.Следующий() Цикл

			Если ВыборкаОтчеты.Родитель <> Родитель Тогда
				Продолжить;
			КонецЕсли;

			Если ВыборкаОтчеты.ИсточникОтчета <> Источник Тогда
				Продолжить;
			КонецЕсли;

			Возврат ВыборкаОтчеты.Ссылка;

		КонецЦикла;

	КонецЕсли;

	Возврат Неопределено;

КонецФункции // ПоискЭлементаПоРеквизитам()

Функция РазложитьСтрокуПериодов(Периоды)
	
	ПериодыПредставления = Новый Соответствие;
	
	Для НомСтр = 1 По СтрЧислоСтрок(Периоды) Цикл
	
		ТекСтр = СтрПолучитьСтроку(Периоды, НомСтр);
		Если ПустаяСтрока(ТекСтр) Тогда
			Продолжить;
		КонецЕсли;
		
		ВхождениеРазделителяНачалаДействия = Найти(ТекСтр, "#");
		СтрПустаяДатаНачалаДействия = "00010101000000";
		Если ВхождениеРазделителяНачалаДействия = 0 Тогда
			СтрДатаНачалаДействия = СтрПустаяДатаНачалаДействия;
		Иначе
			СтрДатаНачалаДействия = СокрЛП(Лев(ТекСтр, ВхождениеРазделителяНачалаДействия - 1));
			ДлинаПредставленияДатыНачала = СтрДлина(СтрДатаНачалаДействия);
			Для Инд = ДлинаПредставленияДатыНачала + 1 По СтрДлина(СтрПустаяДатаНачалаДействия) Цикл
				СтрДатаНачалаДействия = СтрДатаНачалаДействия + Сред(СтрПустаяДатаНачалаДействия, Инд, 1);
			КонецЦикла;
		КонецЕсли;
		ДатаНачалаДействия = Дата(СтрДатаНачалаДействия);
		
		ТекСтр = СокрЛП(Сред(ТекСтр, ВхождениеРазделителяНачалаДействия + 1));
		
		МассивСлов = Новый Массив;
		ПредыдущийРазделитель = 0;
		
		Для Сч = 1 По СтрДлина(ТекСтр) Цикл
			
			Если Сред(ТекСтр, Сч, 1) = ";" Тогда
				Слово = СокрЛП(Сред(ТекСтр, ПредыдущийРазделитель + 1, Сч - ПредыдущийРазделитель - 1));
				Если ПустаяСтрока(Слово) Тогда
					Продолжить;
				КонецЕсли;
				МассивСлов.Добавить(Слово);
				ПредыдущийРазделитель = Сч;
			КонецЕсли;
			
		КонецЦикла;
		
		Слово = СокрЛП(Сред(ТекСтр, ПредыдущийРазделитель + 1));
		Если НЕ ПустаяСтрока(Слово) Тогда
			МассивСлов.Добавить(Слово);
		КонецЕсли;
		
		СтруктураТекущегоПериода = Новый Структура;
		Для Каждого Слово Из МассивСлов Цикл
			
			ВхождениеДвоеточия = Найти(Слово, ":");
			Если ВхождениеДвоеточия = 0 Тогда
				Продолжить;
			КонецЕсли;
			Ключ = СокрЛП(Лев(Слово, ВхождениеДвоеточия - 1));
			Значение = СокрЛП(Сред(Слово, ВхождениеДвоеточия + 1));
			
			МассивИнтервалов = Новый Массив;
			ПредыдущийРазделитель = 0;
			Для Сч = 1 По СтрДлина(Значение) Цикл
				
				Если Сред(Значение, Сч, 1) = "," Тогда
					МассивИнтервалов.Добавить(Число(СокрЛП(Сред(Значение, ПредыдущийРазделитель + 1, Сч - ПредыдущийРазделитель - 1))));
					ПредыдущийРазделитель = Сч;
				КонецЕсли;
			
			КонецЦикла;
			
			Интервал = СокрЛП(Сред(Значение, ПредыдущийРазделитель + 1));
			Если НЕ ПустаяСтрока(Интервал) Тогда
				МассивИнтервалов.Добавить(Число(Интервал));
			КонецЕсли;
			
			СтруктураТекущегоПериода.Вставить(Ключ, МассивИнтервалов);
				
		КонецЦикла;
		
		ПериодыПредставления.Вставить(ДатаНачалаДействия, СтруктураТекущегоПериода);
		
	КонецЦикла;
	
	Возврат ПериодыПредставления;
	
КонецФункции

Функция НомерКолонкиПоИДКонфигурации()
	
	ИдКонф = РегламентированнаяОтчетность.ИДКонфигурации();
	Если ИдКонф = "БП" Тогда
		Возврат 6;
	ИначеЕсли ИдКонф = "УПП" Тогда
		Возврат 7;
	ИначеЕсли ИдКонф = "ЗУП" Тогда
		Возврат 8;
	ИначеЕсли ИдКонф = "ББУ" Тогда
		Возврат 9;
	ИначеЕсли ИдКонф = "ЗБУ" Тогда
		Возврат 10;
	ИначеЕсли ИдКонф = "БПКОРП" Тогда
		Возврат 11;
	ИначеЕсли ИдКонф = "БАУКОРП" ИЛИ ИдКонф = "БАУ" Тогда
		Возврат 12;
	ИначеЕсли ИдКонф = "КА" Тогда
		Возврат 13;
	ИначеЕсли ИдКонф = "БГУ" Тогда
		Возврат 14;
	КонецЕсли;
	
КонецФункции

Процедура ПредупредитьПользователя(ТекстПредупреждения)

	#Если ТолстыйКлиентОбычноеПриложение Тогда
	    Предупреждение(ТекстПредупреждения);
	#КонецЕсли
	#Если ВнешнееСоединение Тогда
		ЗаписьЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка,,, ТекстПредупреждения);
	#КонецЕсли
	#Если Сервер Тогда
		ОбщегоНазначения.СообщитьОбОшибке(ТекстПредупреждения);
	#КонецЕсли

КонецПроцедуры


// Получает список регламентированных отчетов по шаблону, представленному
// в макете СписокОтчетов объекта Справочик.РегламентированныеОтчеты.
//
Функция ПолучитьСписокОтчетов() Экспорт

	Перем ДеревоОтчетов;

	ОписаниеТиповСтрока = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(1000);

	ОписаниеТиповЧисло  = ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(1);

	МассивБулево = Новый Массив;
	МассивБулево.Добавить(Тип("Булево"));
	ОписаниеТиповБулево = Новый ОписаниеТипов(МассивБулево);

	// Дерево значений содержит иерархию элементов справочника РегламентированныеОтчеты.
	// В колонках дерева значений отображается следующая информация:
	//   - наименование отчета;
	//   - описание отчета;
	//   - место нахождения отчета;
	//   - метка выбора отчета.
	ДеревоОтчетов = Новый ДеревоЗначений;
	ДеревоОтчетов.Колонки.Добавить( "Наименование", ОписаниеТиповСтрока );
	ДеревоОтчетов.Колонки.Добавить( "Описание",     ОписаниеТиповСтрока );
	ДеревоОтчетов.Колонки.Добавить( "Источник",     ОписаниеТиповСтрока );
	ДеревоОтчетов.Колонки.Добавить( "ЭтоГруппа",    ОписаниеТиповБулево );
	ДеревоОтчетов.Колонки.Добавить( "МеткаВыбора",  ОписаниеТиповЧисло  );
	ДеревоОтчетов.Колонки.Добавить( "Периоды",  	ОписаниеТиповСтрока );

	// Шаблон списка отчетов в макете имеет следующую структуру:
	//   Каждая именованная область макета содержит элементы одной группы.
	//   При отсутствии имени группы в первой колонке первой строки области
	//   элементы, содержащиеся в этой области, принимаются за элементы корневого
	//   уровня (0-уровня). Элементы создаются в том же порядке, в котором они
	//   перечислены в макете.
	
	НомерКолонкиМакетаСпискаОтчетов = НомерКолонкиПоИДКонфигурации();
	Если НомерКолонкиМакетаСпискаОтчетов = Неопределено Тогда
		Возврат ДеревоОтчетов;
	КонецЕсли;
	
	// Получим макет со списком отчетов.
	МакетСписокОтчетов = ЭтотОбъект.ПолучитьМакет("СписокОтчетов");

	Для Инд = 0 По МакетСписокОтчетов.Области.Количество() - 1 Цикл

		ТекОбласть = МакетСписокОтчетов.Области[Инд];
		ИмяОбласти = ТекОбласть.Имя;

		// наименование группы определяется по первой колонке макета
		ИмяГруппы = СокрЛП(МакетСписокОтчетов.Область(ТекОбласть.Верх, 1).Текст);
		ОписаниеГруппы = СокрЛП(МакетСписокОтчетов.Область(ТекОбласть.Верх, 3).Текст);
		
		Если СокрЛП(МакетСписокОтчетов.Область(ТекОбласть.Верх, НомерКолонкиМакетаСпискаОтчетов).Текст) = "-" Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ПустаяСтрока(ИмяГруппы) Тогда

			СтрокаУровня1 = ДеревоОтчетов.Строки.Добавить();
			СтрокаУровня1.Наименование = ИмяГруппы;
			СтрокаУровня1.ЭтоГруппа    = Истина;
			СтрокаУровня1.Описание     = ОписаниеГруппы;
			СтрокаУровня1.МеткаВыбора  = 1;

			Для Ном = ТекОбласть.Верх По ТекОбласть.Низ Цикл
				// перебираем элементы второго уровня
				
				Если СокрЛП(МакетСписокОтчетов.Область(Ном, НомерКолонкиМакетаСпискаОтчетов).Текст) = "-" Тогда
					Продолжить;
				КонецЕсли;
				
				// наименование отчета определяется по второй колонке макета
				Наименование = СокрЛП(МакетСписокОтчетов.Область(Ном, 2).Текст);

				Если ПустаяСтрока(Наименование) Тогда
					// пустые строки пропускаем
					Продолжить;
				КонецЕсли;

				// описание отчета  определяется по третьей колонке макета
				Описание     = СокрЛП(МакетСписокОтчетов.Область(Ном, 3).Текст);
				// место нахождения отчета  определяется по четвертой колонке макета
				Источник     = СокрЛП(МакетСписокОтчетов.Область(Ном, 4).Текст);
				
				Периоды		 = СокрЛП(МакетСписокОтчетов.Область(Ном, 5).Текст);

				СтрокаУровня2 = СтрокаУровня1.Строки.Добавить();
				СтрокаУровня2.Наименование = Наименование;
				СтрокаУровня2.Описание     = Описание;
				СтрокаУровня2.Источник     = Источник;
				СтрокаУровня2.ЭтоГруппа    = Ложь;
				СтрокаУровня2.МеткаВыбора  = 1;
				СтрокаУровня2.Периоды	   = Периоды;

			КонецЦикла;

		Иначе
			// для элемента корневого (0-уровня)
			Для Ном = ТекОбласть.Верх По ТекОбласть.Низ Цикл
				// перебираем элементы второго уровня

				// наименование отчета определяется по второй колонке макета
				Наименование = СокрЛП(МакетСписокОтчетов.Область(Ном, 2).Текст);

				Если ПустаяСтрока(Наименование) Тогда
					// пустые строки пропускаем
					Продолжить;
				КонецЕсли;

				// описание отчета  определяется по третьей колонке макета
				Описание      = СокрЛП(МакетСписокОтчетов.Область(Ном, 3).Текст);
				// место нахождения отчета  определяется по четвертой колонке макета
				Источник      = СокрЛП(МакетСписокОтчетов.Область(Ном, 4).Текст);

				Периоды		 = СокрЛП(МакетСписокОтчетов.Область(Ном, 5).Текст);
				
				СтрокаУровня1 = ДеревоОтчетов.Строки.Добавить();
				СтрокаУровня1.Наименование = Наименование;
				СтрокаУровня1.Описание     = Описание;
				СтрокаУровня1.Источник     = Источник;
				СтрокаУровня1.ЭтоГруппа    = Ложь;
				СтрокаУровня1.МеткаВыбора  = 1;
				СтрокаУровня1.Периоды	   = Периоды;

			КонецЦикла;

		КонецЕсли;

	КонецЦикла;
	
	Возврат ДеревоОтчетов;

КонецФункции // ПолучитьСписокОтчетов()

// Обновляет справочник "Регламентирванные отчеты".
// При отсутствии элементов справочника создает новые.
// Для найденных элементов обновляет реквизиты.
//
Процедура ЗаполнитьСписокОтчетов(ДеревоОтчетов, ПервоеЗаполнение = Ложь) Экспорт

	Перем НайденнаяГруппа;
	Перем НайденныйЭлемент;

	РегламОтчеты = Справочники.РегламентированныеОтчеты;

	// При первом заполнении необходимо убедиться в том, что справочник регламентированной отчетности пустой
	Если ПервоеЗаполнение Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
		               |	РегламентированныеОтчеты.Ссылка
		               |ИЗ
		               |	Справочник.РегламентированныеОтчеты КАК РегламентированныеОтчеты";

		СправочникПустой = Запрос.Выполнить().Пустой();
		Если НЕ СправочникПустой Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Открываем транзакцию
	НачатьТранзакцию();

	Для Каждого СтрокаУровня1 Из ДеревоОтчетов.Строки Цикл
	
		ИмяОтчета = СокрЛП(СтрокаУровня1.Наименование);
		Описание  = СокрЛП(СтрокаУровня1.Описание);
		Источник  = СокрЛП(СтрокаУровня1.Источник);
		ЭтоГруппа = СтрокаУровня1.ЭтоГруппа;
		Метка     = СтрокаУровня1.МеткаВыбора;
		Периоды   = СокрЛП(СтрокаУровня1.Периоды);

		Если Метка = 0 Тогда
			// пропускаем не помеченные отчеты
			Продолжить;
		КонецЕсли;

		Если ЭтоГруппа Тогда

			// При НЕ первом заполнении списка отчетов новая группа создается только
			// в том случае, если не найдена уже существующая группа, а при первом 
			// заполнении новая группа создается всегда, так как справочник - пустой.
			// Признаком необходимости создания группы служит неопределенное значение 
			// переменной НайденнаяГруппа, которая при НЕ первом заполнении может 
			// принимать и конкретное значение.

			Если Не ПервоеЗаполнение Тогда 
				// для группы отчетов
				НайденнаяГруппа = ПоискЭлементаПоРеквизитам(ИмяОтчета, "", Истина, РегламОтчеты.ПустаяСсылка());
				Родитель        = НайденнаяГруппа;
			КонецЕсли;

			Если НайденнаяГруппа = Неопределено Тогда

				// новая группа элементов справочника
				НоваяГруппа              = РегламОтчеты.СоздатьГруппу();
				НоваяГруппа.Наименование = ИмяОтчета;
				//НоваяГруппа.УстановитьНовыйКод();
				//НоваяГруппа.ГенерироватьНовыйКод();

				Попытка
					НоваяГруппа.Записать();
				Исключение
					ПредупредитьПользователя("Не удалось записать элемент справочника:
					|" + ОписаниеОшибки());

					ОтменитьТранзакцию();
					Возврат;
				КонецПопытки;

				Родитель = НоваяГруппа.Ссылка;
				
			Иначе
				
				ГруппаОбъект = НайденнаяГруппа.ПолучитьОбъект();
				ГруппаОбъект.Описание = Описание;
				Попытка
					ГруппаОбъект.Записать();
				Исключение
					ПредупредитьПользователя("Не удалось записать элемент справочника:
					|" + ОписаниеОшибки());

					ОтменитьТранзакцию();
					Возврат;
				КонецПопытки;
				
			КонецЕсли;

			Если СтрокаУровня1.Строки.Количество() > 0 Тогда
				Для Каждого СтрокаУровня2 Из СтрокаУровня1.Строки Цикл

					ИмяОтчета = СокрЛП(СтрокаУровня2.Наименование);
					Описание  = СокрЛП(СтрокаУровня2.Описание);
					Источник  = СокрЛП(СтрокаУровня2.Источник);
					ЭтоГруппа = СтрокаУровня2.ЭтоГруппа;
					Метка     = СтрокаУровня2.МеткаВыбора;
					Периоды   = СокрЛП(СтрокаУровня2.Периоды);

					Если Метка = 0 Тогда
						// пропускаем не помеченные отчеты
						Продолжить;
					КонецЕсли;

				// При НЕ первом заполнении списка отчетов новый элемент создается 
				// только в том случае, если не найден уже существующий элемент, а при
				// первом заполнении новый элемент создается всегда, так как справочник - 
				// пустой. Признаком необходимости создания элемента служит неопределенное
				// значение переменной НайденныйЭлемент, которая при НЕ первом заполнении
				// может принимать и конкретное значение.

				Если Не ПервоеЗаполнение Тогда 
						НайденныйЭлемент = ПоискЭлементаПоРеквизитам(ИмяОтчета, Источник,, Родитель);
					КонецЕсли;

					Если НайденныйЭлемент = Неопределено Тогда

						// создаем новый элемент справочника
						НовыйЭлемент                        = РегламОтчеты.СоздатьЭлемент();
						НовыйЭлемент.Родитель               = Родитель;
						НовыйЭлемент.Наименование           = ИмяОтчета;
						НовыйЭлемент.Описание               = Описание;
						НовыйЭлемент.ИсточникОтчета         = Источник;
						НовыйЭлемент.Периоды				= Новый ХранилищеЗначения(РазложитьСтрокуПериодов(Периоды));
						//НовыйЭлемент.УстановитьНовыйКод(Лев(Родитель.Код, 3));
						//НовыйЭлемент.ГенерироватьНовыйКод();

						Попытка
							НовыйЭлемент.Записать();
						Исключение
							ПредупредитьПользователя("Не удалось записать элемент справочника:
							|" + ОписаниеОшибки());

							ОтменитьТранзакцию();
							Возврат;
						КонецПопытки;

					Иначе

						// обновляем реквизиты найденного элемента
						ТекЭлемент = НайденныйЭлемент.ПолучитьОбъект();
						ТекЭлемент.Наименование = ИмяОтчета;
						ТекЭлемент.Описание     = Описание;
						ТекЭлемент.Периоды		= Новый ХранилищеЗначения(РазложитьСтрокуПериодов(Периоды));

						Попытка
							ТекЭлемент.Записать();
						Исключение
							ПредупредитьПользователя("Не удалось записать элемент справочника:
							|" + ОписаниеОшибки());

							ОтменитьТранзакцию();
							Возврат;
						КонецПопытки;

					КонецЕсли;

				КонецЦикла;
			КонецЕсли;

		Иначе

			Если Не ПервоеЗаполнение Тогда 
				НайденныйЭлемент = ПоискЭлементаПоРеквизитам(ИмяОтчета, Источник,,РегламОтчеты.ПустаяСсылка());
			КонецЕсли;

			Если НайденныйЭлемент = Неопределено Тогда

				// создаем новый элемент справочника
				НовыйЭлемент                        = РегламОтчеты.СоздатьЭлемент();
				НовыйЭлемент.Наименование           = ИмяОтчета;
				НовыйЭлемент.Описание               = Описание;
				НовыйЭлемент.ИсточникОтчета         = Источник;
				НовыйЭлемент.Периоды				= Новый ХранилищеЗначения(РазложитьСтрокуПериодов(Периоды));
				//НовыйЭлемент.УстановитьНовыйКод(Лев(Родитель.Код, 3));
				//НовыйЭлемент.ГенерироватьНовыйКод();

				Попытка
					НовыйЭлемент.Записать();
				Исключение
					ПредупредитьПользователя("Не удалось записать элемент справочника:
					|" + ОписаниеОшибки());

					ОтменитьТранзакцию();
					Возврат;
				КонецПопытки;

			Иначе

				// обновляем реквизиты найденного элемента
				ТекЭлемент = НайденныйЭлемент.ПолучитьОбъект();
				ТекЭлемент.Наименование = ИмяОтчета;
				ТекЭлемент.Описание     = Описание;
				ТекЭлемент.Периоды		= Новый ХранилищеЗначения(РазложитьСтрокуПериодов(Периоды));

				Попытка
					ТекЭлемент.Записать();
				Исключение
					ПредупредитьПользователя("Не удалось записать элемент справочника:
					|" + ОписаниеОшибки());

					ОтменитьТранзакцию();
					Возврат;
				КонецПопытки;

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

	// Завершаем транзакцию
	ЗафиксироватьТранзакцию();

КонецПроцедуры // ЗаполнитьСписокОтчетов()

