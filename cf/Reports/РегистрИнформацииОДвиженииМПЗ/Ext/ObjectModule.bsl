﻿#Если Клиент Тогда
	
Перем НП Экспорт;
Перем ТМЦ2;
Перем ОбластьГруппировки;
Перем НачальныйОстатокКол;
Перем НачальныйОстатокСум;
Перем ВестиСуммовойУчетПоСкладамНУ;
Перем УчетПоСредней;

Функция СформироватьЗапрос()
	
	    Счет = Новый Массив;
		
		Если ВидТМЦ = 1 Тогда
			Счет.Добавить(ПланыСчетов.Хозрасчетный.СырьеИМатериалы);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.ПокупныеПолуфабрикатыИКомплектующие);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.Топливо);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.ЗапасныеЧасти);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.ПрочиеМатериалы);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.СтроительныеМатериалы);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.ИнвентарьИХозяйственныеПринадлежности);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.СпецоснасткаИСпецодеждаНаСкладе);
			СчетОтгрузки = ПланыСчетов.Хозрасчетный.ПрочиеТоварыОтгруженные;
		ИначеЕсли ВидТМЦ = 2 Тогда
			Счет.Добавить(ПланыСчетов.Хозрасчетный.ГотоваяПродукция);
			Счет.Добавить(ПланыСчетов.Хозрасчетный.Полуфабрикаты);

			СчетОтгрузки = ПланыСчетов.Хозрасчетный.ГотоваяПродукцияОтгруженная;
		Иначе
			
			СчетаУчетаТоваров = ПланыСчетов.Хозрасчетный.ВыбратьИерархически(ПланыСчетов.Хозрасчетный.Товары);
			Пока СчетаУчетаТоваров.Следующий() Цикл
				Если Лев(СчетаУчетаТоваров.Код, 5) = "41.03" Тогда
					Продолжить;
				КонецЕсли;
				
				Счет.Добавить(СчетаУчетаТоваров.Ссылка);
			КонецЦикла;
			СчетОтгрузки = ПланыСчетов.Хозрасчетный.ПокупныеТоварыОтгруженные;
		КонецЕсли;	
		
		Счет45 = СчетОтгрузки;
	    Счет10 = ПланыСчетов.Хозрасчетный.МатериалыПереданныеВПереработку;
		Счет42 = ПланыСчетов.Хозрасчетный.ТорговаяНаценкаАТТ;
		
	Счет.Добавить(Счет42);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("НачалоПериода", ДатаНач);
	Запрос.УстановитьПараметр("КонецПериода",  КонецДня(ДатаКон)); 
	Запрос.УстановитьПараметр("Организация",   Организация);
	
	СчетРасчетов = Новый Массив;
	СчетРасчетов.Добавить(ПланыСчетов.Хозрасчетный.РасчетыСПоставщикамиИПодрядчиками);
	СчетРасчетов.Добавить(ПланыСчетов.Хозрасчетный.РасчетыСПокупателямиИЗаказчиками);
	СчетРасчетов.Добавить(ПланыСчетов.Хозрасчетный.РасчетыСРазнымиДебиторамиИКредиторами);

	Если ВидОтчета = 1 Тогда
    	Запрос.УстановитьПараметр("СчетПВ", СчетРасчетов);
		Запрос.УстановитьПараметр("Счет",   Счет);
		КорСчет = Новый Массив;
		КорСчет.Добавить(Счет10);
		КорСчет.Добавить(Счет45);
		Запрос.УстановитьПараметр("КорСчет",КорСчет);
	ИначеЕсли ВидОтчета = 2 Тогда
	    Запрос.УстановитьПараметр("СчетПВ",  Счет);
		Запрос.УстановитьПараметр("Счет",    Счет45);	
		Запрос.УстановитьПараметр("КорСчет", Счет10);
	ИначеЕсли ВидОтчета = 3 Тогда
	    Запрос.УстановитьПараметр("СчетПВ",  Счет);
		Запрос.УстановитьПараметр("Счет",    Счет10);
		Запрос.УстановитьПараметр("КорСчет", Счет45);	
	КонецЕсли;
	Запрос.УстановитьПараметр("Счет10",      Счет10);	
	Запрос.УстановитьПараметр("Счет45",      Счет45);
	Запрос.УстановитьПараметр("Счет42",      Счет42);
	Запрос.УстановитьПараметр("СкладКонтрагент",?(ВидОтчета = 1, ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады, ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты));
	Запрос.УстановитьПараметр("Номенклатура",ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура);
	Запрос.УстановитьПараметр("Партии",      ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Партии);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА Приход.СубконтоДт1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Приход.СубконтоДт1
	|		КОГДА Приход.СубконтоДт2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Приход.СубконтоДт2
	|		ИНАЧЕ Приход.СубконтоДт3
	|	КОНЕЦ КАК Номенклатура,
	|	ВЫБОР
	|		КОГДА Приход.СубконтоДт1 ССЫЛКА Справочник.Склады
	|			ТОГДА Приход.СубконтоДт1
	|		КОГДА Приход.СубконтоДт2 ССЫЛКА Справочник.Склады
	|			ТОГДА Приход.СубконтоДт2
	|		ИНАЧЕ Приход.СубконтоДт3
	|	КОНЕЦ КАК Склад,
	|	ВЫБОР
	|		КОГДА (НЕ Приход.СубконтоДт1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Приход.СубконтоДт1 ССЫЛКА Справочник.Склады)
	|			ТОГДА Приход.СубконтоДт1
	|		КОГДА (НЕ Приход.СубконтоДт2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Приход.СубконтоДт2 ССЫЛКА Справочник.Склады)
	|			ТОГДА Приход.СубконтоДт2
	|		ИНАЧЕ Приход.СубконтоДт3
	|	КОНЕЦ КАК ДокументОприходования,
	|	Приход.Регистратор КАК Регистратор,
	|	Приход.Период КАК ТекПериод,
	|	ЕСТЬNULL(Приход.КоличествоДт, 0) КАК КоличествоОборотДт,
	|	ВЫБОР
	|		КОГДА (НЕ Приход.СчетКт = &Счет42)
	|			ТОГДА ЕСТЬNULL(Приход.СуммаНУДт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ + ВЫБОР
	|		КОГДА Приход.СчетКт = &Счет42
	|				И Приход.СуммаНУКт < 0
	|			ТОГДА Приход.СуммаНУКт
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК СуммаОборотДт,
	|	0 КАК КоличествоОборотКт,
	|	0 КАК СуммаОборотКт,
	|	0 КАК КоличествоОборотВозврат,
	|	0 КАК СуммаОборотВозврат,
	|	0 КАК КоличествоОборотОтгружено,
	|	0 КАК СуммаОборотОтгружено,
	|	0 КАК КоличествоОборотПередано,
	|	0 КАК СуммаОборотПередано,
	|	0 КАК КоличествоНачальныйОстаток,
	|	0 КАК СуммаНачальныйОстаток
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			СчетДт В ИЕРАРХИИ (&Счет)
	|				И Организация = &Организация
	|				И Активность
	|				И (НЕ СчетКт В ИЕРАРХИИ (&КорСчет))) КАК Приход
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА Выбытие.СубконтоКт1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Выбытие.СубконтоКт1
	|		КОГДА Выбытие.СубконтоКт2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Выбытие.СубконтоКт2
	|		ИНАЧЕ Выбытие.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА Выбытие.СубконтоКт1 ССЫЛКА Справочник.Склады
	|			ТОГДА Выбытие.СубконтоКт1
	|		КОГДА Выбытие.СубконтоКт2 ССЫЛКА Справочник.Склады
	|			ТОГДА Выбытие.СубконтоКт2
	|		ИНАЧЕ Выбытие.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА (НЕ Выбытие.СубконтоКт1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Выбытие.СубконтоКт1 ССЫЛКА Справочник.Склады)
	|			ТОГДА Выбытие.СубконтоКт1
	|		КОГДА (НЕ Выбытие.СубконтоКт2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Выбытие.СубконтоКт2 ССЫЛКА Справочник.Склады)
	|			ТОГДА Выбытие.СубконтоКт2
	|		ИНАЧЕ Выбытие.СубконтоКт3
	|	КОНЕЦ,
	|	Выбытие.Регистратор,
	|	Выбытие.Период,
	|	0,
	|	0,
	|	ЕСТЬNULL(Выбытие.КоличествоКт, 0),
	|	ВЫБОР
	|		КОГДА (НЕ Выбытие.СчетКт = &Счет42)
	|			ТОГДА ЕСТЬNULL(Выбытие.СуммаНУКт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ + ВЫБОР
	|		КОГДА Выбытие.СчетКт = &Счет42
	|				И Выбытие.СуммаНУКт < 0
	|			ТОГДА Выбытие.СуммаНУКт
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			СчетКт В ИЕРАРХИИ (&Счет)
	|				И Организация = &Организация
	|				И Активность
	|				И (НЕ СчетДт В ИЕРАРХИИ (&КОРСчет))
	|				И (НЕ СчетДт В ИЕРАРХИИ (&СчетПВ))) КАК Выбытие
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА Возвраты.СубконтоКт1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Возвраты.СубконтоКт1
	|		КОГДА Возвраты.СубконтоКт2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Возвраты.СубконтоКт2
	|		ИНАЧЕ Возвраты.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА Возвраты.СубконтоКт1 ССЫЛКА Справочник.Склады
	|			ТОГДА Возвраты.СубконтоКт1
	|		КОГДА Возвраты.СубконтоКт2 ССЫЛКА Справочник.Склады
	|			ТОГДА Возвраты.СубконтоКт2
	|		ИНАЧЕ Возвраты.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА (НЕ Возвраты.СубконтоКт1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Возвраты.СубконтоКт1 ССЫЛКА Справочник.Склады)
	|			ТОГДА Возвраты.СубконтоКт1
	|		КОГДА (НЕ Возвраты.СубконтоКт2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Возвраты.СубконтоКт2 ССЫЛКА Справочник.Склады)
	|			ТОГДА Возвраты.СубконтоКт2
	|		ИНАЧЕ Возвраты.СубконтоКт3
	|	КОНЕЦ,
	|	Возвраты.Регистратор,
	|	Возвраты.Период,
	|	0,
	|	0,
	|	0,
	|	0,
	|	ЕСТЬNULL(Возвраты.КоличествоКт, 0),
	|	ЕСТЬNULL(Возвраты.СуммаНУКт, 0) + ВЫБОР
	|		КОГДА Возвраты.СчетДт В ИЕРАРХИИ (&СчетПВ)
	|				И Возвраты.СчетДт = &Счет42
	|			ТОГДА Возвраты.СуммаНУКт
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			СчетКт В ИЕРАРХИИ (&Счет)
	|				И Организация = &Организация
	|				И Активность
	|				И СчетДт В ИЕРАРХИИ (&СчетПВ)) КАК Возвраты
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СубконтоКт1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА ОтгруженоПередано.СубконтоКт1
	|		КОГДА ОтгруженоПередано.СубконтоКт2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА ОтгруженоПередано.СубконтоКт2
	|		ИНАЧЕ ОтгруженоПередано.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СубконтоКт1 ССЫЛКА Справочник.Склады
	|			ТОГДА ОтгруженоПередано.СубконтоКт1
	|		КОГДА ОтгруженоПередано.СубконтоКт2 ССЫЛКА Справочник.Склады
	|			ТОГДА ОтгруженоПередано.СубконтоКт2
	|		ИНАЧЕ ОтгруженоПередано.СубконтоКт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА (НЕ ОтгруженоПередано.СубконтоКт1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ ОтгруженоПередано.СубконтоКт1 ССЫЛКА Справочник.Склады)
	|			ТОГДА ОтгруженоПередано.СубконтоКт1
	|		КОГДА (НЕ ОтгруженоПередано.СубконтоКт2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ ОтгруженоПередано.СубконтоКт2 ССЫЛКА Справочник.Склады)
	|			ТОГДА ОтгруженоПередано.СубконтоКт2
	|		ИНАЧЕ ОтгруженоПередано.СубконтоКт3
	|	КОНЕЦ,
	|	ОтгруженоПередано.Регистратор,
	|	ОтгруженоПередано.Период,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СчетДт В ИЕРАРХИИ (&Счет45)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПередано.КоличествоКт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СчетДт В ИЕРАРХИИ (&Счет45)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПередано.Сумма, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СчетДт В ИЕРАРХИИ (&Счет10)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПередано.КоличествоКт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ОтгруженоПередано.СчетДт В ИЕРАРХИИ (&Счет10)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПередано.Сумма, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	0,
	|	0
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			СчетКт В ИЕРАРХИИ (&Счет)
	|				И СчетДт В ИЕРАРХИИ (&КорСчет)
	|				И Организация = &Организация
	|				И Активность) КАК ОтгруженоПередано
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СубконтоДт1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт1
	|		КОГДА ОтгруженоПереданоВозврат.СубконтоДт2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт2
	|		ИНАЧЕ ОтгруженоПереданоВозврат.СубконтоДт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СубконтоДт1 ССЫЛКА Справочник.Склады
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт1
	|		КОГДА ОтгруженоПереданоВозврат.СубконтоДт2 ССЫЛКА Справочник.Склады
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт2
	|		ИНАЧЕ ОтгруженоПереданоВозврат.СубконтоДт3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА (НЕ ОтгруженоПереданоВозврат.СубконтоДт1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ ОтгруженоПереданоВозврат.СубконтоДт1 ССЫЛКА Справочник.Склады)
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт1
	|		КОГДА (НЕ ОтгруженоПереданоВозврат.СубконтоДт2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ ОтгруженоПереданоВозврат.СубконтоДт2 ССЫЛКА Справочник.Склады)
	|			ТОГДА ОтгруженоПереданоВозврат.СубконтоДт2
	|		ИНАЧЕ ОтгруженоПереданоВозврат.СубконтоДт3
	|	КОНЕЦ,
	|	ОтгруженоПереданоВозврат.Регистратор,
	|	ОтгруженоПереданоВозврат.Период,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	-ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СчетКт В ИЕРАРХИИ (&Счет45)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПереданоВозврат.КоличествоДт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	-ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СчетКт В ИЕРАРХИИ (&Счет45)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПереданоВозврат.Сумма, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	-ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СчетКт В ИЕРАРХИИ (&Счет10)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПереданоВозврат.КоличествоДт, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	-ВЫБОР
	|		КОГДА ОтгруженоПереданоВозврат.СчетКт В ИЕРАРХИИ (&Счет10)
	|			ТОГДА ЕСТЬNULL(ОтгруженоПереданоВозврат.Сумма, 0)
	|		ИНАЧЕ 0
	|	КОНЕЦ,
	|	0,
	|	0
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ДвиженияССубконто(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			СчетДт В ИЕРАРХИИ (&Счет)
	|				И СчетКт В ИЕРАРХИИ (&КорСчет)
	|				И Организация = &Организация
	|				И Активность) КАК ОтгруженоПереданоВозврат
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА Остатки.Субконто1 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Остатки.Субконто1
	|		КОГДА Остатки.Субконто2 ССЫЛКА Справочник.Номенклатура
	|			ТОГДА Остатки.Субконто2
	|		ИНАЧЕ Остатки.Субконто3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА Остатки.Субконто1 ССЫЛКА Справочник.Склады
	|			ТОГДА Остатки.Субконто1
	|		КОГДА Остатки.Субконто2 ССЫЛКА Справочник.Склады
	|			ТОГДА Остатки.Субконто2
	|		ИНАЧЕ Остатки.Субконто3
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА (НЕ Остатки.Субконто1 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Остатки.Субконто1 ССЫЛКА Справочник.Склады)
	|			ТОГДА Остатки.Субконто1
	|		КОГДА (НЕ Остатки.Субконто2 ССЫЛКА Справочник.Номенклатура)
	|				И (НЕ Остатки.Субконто2 ССЫЛКА Справочник.Склады)
	|			ТОГДА Остатки.Субконто2
	|		ИНАЧЕ Остатки.Субконто3
	|	КОНЕЦ,
	|	NULL,
	|	NULL,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	ЕСТЬNULL(Остатки.КоличествоОстаток, 0),
	|	ЕСТЬNULL(Остатки.СуммаОстатокДт - Остатки.СуммаОстатокКт, 0)
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки(&НачалоПериода, Счет В ИЕРАРХИИ (&Счет), , Организация = &Организация) КАК Остатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТекПериод
	|ИТОГИ
	|	СУММА(КоличествоОборотДт),
	|	СУММА(СуммаОборотДт),
	|	СУММА(КоличествоОборотКт),
	|	СУММА(СуммаОборотКт),
	|	СУММА(КоличествоОборотВозврат),
	|	СУММА(СуммаОборотВозврат),
	|	СУММА(КоличествоОборотОтгружено),
	|	СУММА(СуммаОборотОтгружено),
	|	СУММА(КоличествоОборотПередано),
	|	СУММА(СуммаОборотПередано),
	|	СУММА(КоличествоНачальныйОстаток),
	|	СУММА(СуммаНачальныйОстаток)
	|ПО
	|	ДокументОприходования,
	|	Склад,
	|	Номенклатура,
	|	Регистратор,
	|	ТекПериод";
	
	
		Если Не ВидОтчета = 1 Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "Справочник.Склады", "Справочник.Контрагенты");	
		КонецЕсли;

	ОграниченияПоПостроителюОтчета = СтандартныеОтчеты.ПолучитьТекстОграниченийПоПостроителюОтчета(ПостроительОтчета, Запрос);
	
	Если Не ПустаяСтрока(ОграниченияПоПостроителюОтчета) Тогда
		
		ОграниченияПоПостроителюОтчета = " И " + ОграниченияПоПостроителюОтчета;
		
	КонецЕсли;
	
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "И Активность", "И Активность" + ОграниченияПоПостроителюОтчета);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, ") КАК Остатки", "" + ОграниченияПоПостроителюОтчета + ") КАК Остатки");
	
	 Возврат Запрос.Выполнить();
КонецФункции

// Обход результатов запроса по номенклатуре и регистратору
Процедура ВывестиПоТМЦНаСкладеНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаТекущая, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено, ВсегоПереработка = 0)
	
	ОбластьНоменклатура  = Макет.ПолучитьОбласть("Номенклатура");
	ОбластьСтрока        = Макет.ПолучитьОбласть("Строка");
	
	ВыборкаНоменклатуры = ВыборкаТекущая.Выбрать(СпособВыборки, "Номенклатура");
	Пока ВыборкаНоменклатуры.Следующий() Цикл
		
		ИтоговаяСтрокаНоменклатуры = "    По "+ТМЦ2+": """ + ВыборкаНоменклатуры.Номенклатура + """   Сальдо на начало периода: " +
		Формат(ВыборкаНоменклатуры.СуммаНачальныйОстаток, "ЧДЦ=2");
		ОбластьНоменклатура.Параметры.ИтоговаяСтрокаНоменклатуры = ИтоговаяСтрокаНоменклатуры;
		ДокументРезультат.Вывести(ОбластьНоменклатура);
		НачальныйОстатокКол = ВыборкаНоменклатуры.КоличествоНачальныйОстаток;
		НачальныйОстатокСум = ?(НЕ ВестиСуммовойУчетПоСкладамНУ, 0, ВыборкаНоменклатуры.СуммаНачальныйОстаток);
		
		КоэфПриход    = ?(ВыборкаНоменклатуры.КоличествоОборотДт = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотДт);
		КоэфВыбытие   = ?(ВыборкаНоменклатуры.КоличествоОборотКт = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотКт); 
		КоэфВозврат   = ?(ВыборкаНоменклатуры.КоличествоОборотВозврат = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотВозврат); 
		КоэфОтгружено = ?(ВыборкаНоменклатуры.КоличествоОборотОтгружено = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотОтгружено); 
		КоэфПередано  = ?(ВыборкаНоменклатуры.КоличествоОборотПередано = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотПередано);
		КорректировкаПриход    = 0;
		КорректировкаВыбытие   = 0; 
		КорректировкаВозврат   = 0; 
		КорректировкаОтгружено = 0; 
		КорректировкаПередано  = 0;
		
		Выборка = ВыборкаНоменклатуры.Выбрать(СпособВыборки,"Регистратор");
		Пока Выборка.Следующий() Цикл
			
			ВыборкаСтрок = Выборка.Выбрать(СпособВыборки);
			Пока ВыборкаСтрок.Следующий() Цикл
				
				Если ВыборкаСтрок.Регистратор = NULL Тогда
					КорректировкаПриход    = ВыборкаСтрок.СуммаОборотДт;
					КорректировкаВыбытие   = ВыборкаСтрок.СуммаОборотКт; 
					КорректировкаВозврат   = ВыборкаСтрок.СуммаОборотВозврат; 
					КорректировкаОтгружено = ВыборкаСтрок.СуммаОборотОтгружено; 
					КорректировкаПередано  = ВыборкаСтрок.СуммаОборотПередано;
					Продолжить;
				КонецЕсли;
				
				ОбластьСтрока.Параметры.ДатаОперации = ВыборкаСтрок.ТекПериод;
				ОбластьСтрока.Параметры.ОснованиеОперации = ВыборкаСтрок.Регистратор;
				
				ВозвратСумма = 0;
				СписаниеСумма = 0;
				ОтгруженоСумма = 0;
				ПереработкаСумма = 0;
				
				ОбластьСтрока.Параметры.ВозвратКоличество = ВыборкаСтрок.КоличествоОборотВозврат;
				ВозвратСумма =  ВыборкаСтрок.СуммаОборотВозврат + КорректировкаВозврат * ВыборкаСтрок.КоличествоОборотВозврат * КоэфВозврат;
				ОбластьСтрока.Параметры.ВозвратСумма =  ВозвратСумма;
				ВсегоВозврат = ВсегоВозврат + ВозвратСумма;
				
				ОбластьСтрока.Параметры.ПереработкаКоличество = ВыборкаСтрок.КоличествоОборотПередано;
				ПереданоСумма = ВыборкаСтрок.СуммаОборотПередано + КорректировкаПередано * ВыборкаСтрок.КоличествоОборотПередано * КоэфПередано;
				ОбластьСтрока.Параметры.ПереработкаСумма = ПереданоСумма;
				ВсегоПереработка = ВсегоПереработка + ПереданоСумма;
				
				ОбластьСтрока.Параметры.СписаниеКоличество = ВыборкаСтрок.КоличествоОборотКт;
				СписаниеСумма = ВыборкаСтрок.СуммаОборотКт + КорректировкаВыбытие * ВыборкаСтрок.КоличествоОборотКт * КоэфВыбытие;
				ОбластьСтрока.Параметры.СписаниеСумма = СписаниеСумма;
				ВсегоСписание = ВсегоСписание + СписаниеСумма;
				
				ОбластьСтрока.Параметры.ОтгруженоКоличество = ВыборкаСтрок.КоличествоОборотОтгружено;
				ОтгруженоСумма = ВыборкаСтрок.СуммаОборотОтгружено + КорректировкаОтгружено * ВыборкаСтрок.КоличествоОборотОтгружено * КоэфОтгружено;
				ОбластьСтрока.Параметры.ОтгруженоСумма = ОтгруженоСумма;
				ВсегоОтгружено = ВсегоОтгружено + ОтгруженоСумма;
				
				ОбластьСтрока.Параметры.ПриходКоличество = ВыборкаСтрок.КоличествоОборотДт;
				ПриходСумма =  ВыборкаСтрок.СуммаОборотДт + КорректировкаПриход * ВыборкаСтрок.КоличествоОборотДт * КоэфПриход;
				ОбластьСтрока.Параметры.ПриходСумма = ПриходСумма;
				ВсегоПриход = ВсегоПриход + ПриходСумма;
				
				ВсегоОборотКол = ВыборкаСтрок.КоличествоОборотДт - ВыборкаСтрок.КоличествоОборотКт - ВыборкаСтрок.КоличествоОборотВозврат - ВыборкаСтрок.КоличествоОборотОтгружено - ВыборкаСтрок.КоличествоОборотПередано;
				ВсегоОборотСум = ПриходСумма - СписаниеСумма - ВыборкаСтрок.СуммаОборотВозврат - ВыборкаСтрок.СуммаОборотОтгружено - ВыборкаСтрок.СуммаОборотПередано;
				НачальныйОстатокКол = НачальныйОстатокКол + ВсегоОборотКол;
				НачальныйОстатокСум = НачальныйОстатокСум + ВсегоОборотСум;
				ОбластьСтрока.Параметры.ОстатокКоличество = НачальныйОстатокКол;
				ОбластьСтрока.Параметры.ОстатокСумма = НачальныйОстатокСум;
				
				СписаниеЦена = ?(ВсегоОборотКол <> 0, ВсегоОборотСум /ВсегоОборотКол, 0);
				ОбластьСтрока.Параметры.СписаниеЦена = СписаниеЦена;
				ДокументРезультат.Вывести(ОбластьСтрока);
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Процедура ВывестиПоТМЦНаСкладе(ДокументРезультат, Макет, Результат, УчетнаяПолитика)
	
	ОбластьПодвал        = Макет.ПолучитьОбласть("Подвал");	
	ОбластьИтоги		 = Макет.ПолучитьОбласть("Итоги");
	ОбластьГруппировки   = Макет.ПолучитьОбласть("Итоговая2");
	ОбластьПартии        = Макет.ПолучитьОбласть("Номенклатура");	
	ВсегоПриход = 0;
	ВсегоВозврат = 0;
	ВсегоСписание = 0;
	ВсегоОтгружено = 0;
	ВсегоПереработка = 0;
	СпособВыборки = ОбходРезультатаЗапроса.ПоГруппировкам;
	
	Если  УчетнаяПолитика = Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() = 1 Тогда
		
		ВывестиПоТМЦНаСкладеНоменклатураРегистратор(ДокументРезультат,Макет, Результат, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено, ВсегоПереработка);	
	ИначеЕсли  УчетнаяПолитика = Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() <> 1 Тогда
		
		ВыборкаСклад = Результат.Выбрать(СпособВыборки,"Склад");
		Пока ВыборкаСклад.Следующий() Цикл
			
			Если Не ЗначениеЗаполнено(ВыборкаСклад.Склад) Тогда
				Продолжить;
			КонецЕсли;

			    ИтоговаяСтрока2 = "        По складу: """ + ВыборкаСклад.Склад + """   Сальдо на начало периода: " +
				Формат(ВыборкаСклад.СуммаНачальныйОстаток, "ЧДЦ=2");
				ОбластьГруппировки.Параметры.ИтоговаяСтрока2 = ИтоговаяСтрока2;
				ДокументРезультат.Вывести(ОбластьГруппировки);
			
			ВывестиПоТМЦНаСкладеНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаСклад,СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено, ВсегоПереработка);	
		КонецЦикла;
	ИначеЕсли  УчетнаяПолитика <> Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() = 1 Тогда
		
		ВыборкаПартия = Результат.Выбрать(СпособВыборки,"ДокументОприходования");
		Пока ВыборкаПартия.Следующий() Цикл
				ИтоговаяСтрокаНоменклатуры = "По партии: """ + ВыборкаПартия.ДокументОприходования + """   Сальдо на начало периода: " +
				Формат(ВыборкаПартия.СуммаНачальныйОстаток, "ЧДЦ=2");
				ОбластьПартии.Параметры.ИтоговаяСтрокаНоменклатуры  = ИтоговаяСтрокаНоменклатуры;
				ДокументРезультат.Вывести(ОбластьПартии);
			    ВывестиПоТМЦНаСкладеНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаПартия,СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено, ВсегоПереработка);	
		КонецЦикла;
	Иначе		
		ВыборкаПартия = Результат.Выбрать(СпособВыборки,"ДокументОприходования");
		Пока ВыборкаПартия.Следующий() Цикл
				ИтоговаяСтрокаНоменклатуры = "По партии: """ + ВыборкаПартия.ДокументОприходования + """   Сальдо на начало периода: " +
				Формат(ВыборкаПартия.СуммаНачальныйОстаток, "ЧДЦ=2");
				ОбластьПартии.Параметры.ИтоговаяСтрокаНоменклатуры  = ИтоговаяСтрокаНоменклатуры;
				ДокументРезультат.Вывести(ОбластьПартии);
			ВыборкаСклад = ВыборкаПартия.Выбрать(СпособВыборки,"Склад");
			Пока ВыборкаСклад.Следующий() Цикл
				
				Если Не ЗначениеЗаполнено(ВыборкаСклад.Склад) Тогда
					Продолжить;
				КонецЕсли;
				ИтоговаяСтрока2 = "        По складу: """ + ВыборкаСклад.Склад + """   Сальдо на начало периода: " +
				Формат(ВыборкаСклад.СуммаНачальныйОстаток, "ЧДЦ=2");
				ОбластьГруппировки.Параметры.ИтоговаяСтрока2 = ИтоговаяСтрока2;
				ДокументРезультат.Вывести(ОбластьГруппировки);
				
				ВывестиПоТМЦНаСкладеНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаСклад,СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено, ВсегоПереработка);	
			КонецЦикла;
		КонецЦикла;
КонецЕсли;

	ОбластьИтоги.Параметры.ВсегоПриходСумма = ВсегоПриход;
	ОбластьИтоги.Параметры.ВсегоВозвратСумма = ВсегоВозврат;
	ОбластьИтоги.Параметры.ВсегоСписаниеСумма = ВсегоСписание;
	ОбластьИтоги.Параметры.ВсегоОтгруженоСумма = ВсегоОтгружено;
	ОбластьИтоги.Параметры.ВсегоПереработкаСумма = ВсегоПереработка;
	ДокументРезультат.Вывести(ОбластьИтоги);
	
	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);
	
	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = СтруктураЛиц.ОтветственныйЗаРегистры;
	ДокументРезультат.Вывести(ОбластьПодвал);
	
КонецПроцедуры

Процедура ВывестиПоТМЦОтгруженнымНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаТекущая, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено)
	ОбластьНоменклатура  = Макет.ПолучитьОбласть("Номенклатура");
	ОбластьСтрока        = Макет.ПолучитьОбласть("Строка");
	ВыборкаНоменклатуры = ВыборкаТекущая.Выбрать(СпособВыборки, "Номенклатура");
	
	Пока ВыборкаНоменклатуры.Следующий() Цикл
		
		ИтоговаяСтрокаНоменклатуры = "    По "+ТМЦ2+": """ + ВыборкаНоменклатуры.Номенклатура + """   Сальдо на начало периода: " +
		Формат(ВыборкаНоменклатуры.СуммаНачальныйОстаток, "ЧДЦ=2");
		ОбластьНоменклатура.Параметры.ИтоговаяСтрокаНоменклатуры = ИтоговаяСтрокаНоменклатуры;
		ДокументРезультат.Вывести(ОбластьНоменклатура);
		НачальныйОстатокКол = ВыборкаНоменклатуры.КоличествоНачальныйОстаток;
		НачальныйОстатокСум = ВыборкаНоменклатуры.СуммаНачальныйОстаток;
		
		КоэфСписание  = ?(ВыборкаНоменклатуры.КоличествоОборотКт = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотКт); 
		КоэфВозврат   = ?(ВыборкаНоменклатуры.КоличествоОборотВозврат = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотВозврат); 
		КоэфОтгружено = ?(ВыборкаНоменклатуры.КоличествоОборотОтгружено = 0, 0, 1 / ВыборкаНоменклатуры.КоличествоОборотОтгружено); 
		КорректировкаСписание  = 0; 
		КорректировкаВозврат   = 0; 
		КорректировкаОтгружено = 0; 
		
		Выборка = ВыборкаНоменклатуры.Выбрать(СпособВыборки,"Регистратор");
		Пока Выборка.Следующий() Цикл
			ВыборкаСтрок = Выборка.Выбрать(СпособВыборки);
			Пока ВыборкаСтрок.Следующий() Цикл
				
				Если ВыборкаСтрок.Регистратор = Неопределено Тогда
					КорректировкаСписание  = ВыборкаСтрок.СуммаОборотКт; 
					КорректировкаВозврат   = ВыборкаСтрок.СуммаОборотВозврат; 
					КорректировкаОтгружено = ВыборкаСтрок.СуммаОборотОтгружено; 
					Продолжить;
				КонецЕсли;
				
				ОбластьСтрока.Параметры.ДатаОперации = ВыборкаСтрок.ТекПериод;
				ОбластьСтрока.Параметры.ОснованиеОперации = ВыборкаСтрок.Регистратор;

				ОбластьСтрока.Параметры.ВозвратКоличество =  ВыборкаСтрок.КоличествоОборотВозврат;
				ВозвратСумма =  ВыборкаСтрок.СуммаОборотВозврат + КорректировкаВозврат * ВыборкаСтрок.КоличествоОборотВозврат * КоэфВозврат;
				ОбластьСтрока.Параметры.ВозвратСумма = ВозвратСумма;
				ВсегоВозврат = ВсегоВозврат + ВозвратСумма;
				
				ОбластьСтрока.Параметры.СписаниеКоличество = ВыборкаСтрок.КоличествоОборотКт;
				СписаниеСумма = ВыборкаСтрок.СуммаОборотКт + КорректировкаСписание * ВыборкаСтрок.КоличествоОборотКт * КоэфСписание;
				ОбластьСтрока.Параметры.СписаниеСумма = СписаниеСумма;
				ВсегоСписание = ВсегоСписание + СписаниеСумма;
				
				ОбластьСтрока.Параметры.ОтгруженоКоличество = ВыборкаСтрок.КоличествоОборотДт;
				ОтгруженоСумма = ВыборкаСтрок.СуммаОборотДт;
				ОбластьСтрока.Параметры.ОтгруженоСумма = ОтгруженоСумма + КорректировкаОтгружено * ВыборкаСтрок.КоличествоОборотОтгружено * КоэфОтгружено;
				ВсегоОтгружено = ВсегоОтгружено + ОтгруженоСумма;
				
				ВсегоОборотКол =  ВыборкаСтрок.КоличествоОборотДт - ВыборкаСтрок.КоличествоОборотКт - ВыборкаСтрок.КоличествоОборотВозврат;
				ВсегоОборотСум =  ОтгруженоСумма - ВозвратСумма - СписаниеСумма;
				НачальныйОстатокКол = НачальныйОстатокКол + ВсегоОборотКол; 
				НачальныйОстатокСум = НачальныйОстатокСум + ВсегоОборотСум;						
				ОбластьСтрока.Параметры.ОстатокКоличество = НачальныйОстатокКол;
				ОбластьСтрока.Параметры.ОстатокСумма = НачальныйОстатокСум;
				ОбластьСтрока.Параметры.СписаниеЦена = ?(ВсегоОборотКол = 0, 0, ВсегоОборотСум / ВсегоОборотКол);
				ДокументРезультат.Вывести(ОбластьСтрока);
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КОнецПроцедуры

Процедура ВывестиПоТМЦОтгруженным(ДокументРезультат, Макет, Результат, УчетнаяПолитика)
	ОбластьПодвал        = Макет.ПолучитьОбласть("Подвал");
	ОбластьИтоги		 = Макет.ПолучитьОбласть("Итоги");
	ОбластьГруппировки   = Макет.ПолучитьОбласть("Итоговая2");
	ОбластьНоменклатура  = Макет.ПолучитьОбласть("Номенклатура");
	ВсегоПриход = 0;
	ВсегоВозврат = 0;
	ВсегоСписание = 0;
	ВсегоОтгружено = 0;
	УчетнаяПолитикаПоСредней = 0;
	СпособВыборки = ОбходРезультатаЗапроса.ПоГруппировкам;
	
	Если  УчетнаяПолитика = Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() = 1 Тогда
		ВывестиПоТМЦОтгруженнымНоменклатураРегистратор(ДокументРезультат,Макет, Результат, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено);
	ИначеЕсли  УчетнаяПолитика = Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() <> 1 Тогда
		ВыборкаСклад = Результат.Выбрать(СпособВыборки,"Склад");
		Пока ВыборкаСклад.Следующий() Цикл
			
			Если Не ЗначениеЗаполнено(ВыборкаСклад.Склад) Тогда
				Продолжить;
			КонецЕсли;
			
			ИтоговаяСтрока2 = "        По контрагенту: """ + ВыборкаСклад.Склад + """   Сальдо на начало периода: " +
			Формат(ВыборкаСклад.СуммаНачальныйОстаток, "ЧДЦ=2");
			ОбластьГруппировки.Параметры.ИтоговаяСтрока2 = ИтоговаяСтрока2;
			ДокументРезультат.Вывести(ОбластьГруппировки);
			ВывестиПоТМЦОтгруженнымНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаСклад, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено);
		КонецЦикла;
	ИначеЕсли  УчетнаяПолитика <> Перечисления.СпособыОценки.ПоСредней И ПланыСчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Количество() = 1 Тогда
		ВыборкаПартия = Результат.Выбрать(СпособВыборки,"ДокументОприходования");
		Пока ВыборкаПартия.Следующий() Цикл
			ИтоговаяСтрокаНоменклатуры = "По партии: """ + ВыборкаПартия.ДокументОприходования + """   Сальдо на начало периода: " +
			Формат(ВыборкаПартия.СуммаНачальныйОстаток, "ЧДЦ=2");
			ОбластьНоменклатура.Параметры.ИтоговаяСтрокаНоменклатуры = ИтоговаяСтрокаНоменклатуры;
			ДокументРезультат.Вывести(ОбластьНоменклатура);
			ВывестиПоТМЦОтгруженнымНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаПартия, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено);
		КонецЦикла;
	Иначе
		ВыборкаПартия = Результат.Выбрать(СпособВыборки,"ДокументОприходования");
		Пока ВыборкаПартия.Следующий() Цикл
			ИтоговаяСтрокаНоменклатуры = "По партии: """ + ВыборкаПартия.ДокументОприходования + """   Сальдо на начало периода: " + Формат(ВыборкаПартия.СуммаНачальныйОстаток, "ЧДЦ=2");
			ОбластьНоменклатура.Параметры.ИтоговаяСтрокаНоменклатуры = ИтоговаяСтрокаНоменклатуры;
			ДокументРезультат.Вывести(ОбластьНоменклатура);
			ВыборкаСклад = ВыборкаПартия.Выбрать(СпособВыборки,"Склад");
			Пока ВыборкаСклад.Следующий() Цикл
				
			Если Не ЗначениеЗаполнено(ВыборкаСклад.Склад) Тогда
				Продолжить;
			КонецЕсли;
				
				ИтоговаяСтрока2 = "        По контрагенту: """ + ВыборкаСклад.Склад + """   Сальдо на начало периода: " + Формат(ВыборкаСклад.СуммаНачальныйОстаток, "ЧДЦ=2");
				ОбластьГруппировки.Параметры.ИтоговаяСтрока2 = ИтоговаяСтрока2;
				ДокументРезультат.Вывести(ОбластьГруппировки);
				ВывестиПоТМЦОтгруженнымНоменклатураРегистратор(ДокументРезультат,Макет, ВыборкаПартия, СпособВыборки, ВсегоПриход,ВсегоВозврат,ВсегоСписание,ВсегоОтгружено);
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
		ОбластьИтоги.Параметры.ВсегоВозвратСумма = ВсегоВозврат;
		ОбластьИтоги.Параметры.ВсегоСписаниеСумма = ВсегоСписание;
		ОбластьИтоги.Параметры.ВсегоОтгруженоСумма = ВсегоОтгружено;
		ДокументРезультат.Вывести(ОбластьИтоги);
		
		СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);
		
		ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = СтруктураЛиц.ОтветственныйЗаРегистры;
		ДокументРезультат.Вывести(ОбластьПодвал);
		
КонецПроцедуры


// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь) Экспорт
	
	НачалоПериода = ДатаНач;
	КонецПериода = ДатаКон;
	
	ДокументРезультат.Очистить();
	
	Если ВидОтчета = 1 Тогда
		Макет = ПолучитьМакет("НаСкладе");
		
	Иначе
		Макет = ПолучитьМакет("Отгружено");	
	КонецЕсли;
	
	Если ВидТМЦ = 1 Тогда
		ТМЦ = "материалов";     ТМЦ2 = "материалам";       ТМЦ3 = ?(ВидОтчета = 3, " переданным в переработку", " отгруженным");
	ИначеЕсли ВидТМЦ = 2 Тогда
		ТМЦ = "продукции и полуфабрикатов";      ТМЦ2 = "продукции и полуфабрикатам";        ТМЦ3 = ?(ВидОтчета = 3, " переданной в переработку", " отгруженным");
	Иначе
		ТМЦ = "товаров";        ТМЦ2 = "товарам";          ТМЦ3 = ?(ВидОтчета = 3, " переданным в переработку", " отгруженным");
	КонецЕсли;
	
    НачальныйОстатокКол = 0;
	НачальныйОстатокСум = 0;
	
	ОбластьЗаголовок  = Макет.ПолучитьОбласть("Заголовок");
	
	СрезСведений = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(КонецПериода, Ложь, Организация);
	УчетнаяПолитика = ?(СрезСведений.Количество() = 0, Перечисления.СпособыОценки.ПустаяСсылка(), СрезСведений.СпособОценкиМПЗ);
	Если УчетнаяПолитика = Перечисления.СпособыОценки.ФИФО Тогда
		Заголовок = "Регистр информации о партиях "+ТМЦ+", учитываемых по методу ФИФО";
	ИначеЕсли УчетнаяПолитика = Перечисления.СпособыОценки.ЛИФО Тогда
		Заголовок = "Регистр информации о партиях "+ТМЦ+", учитываемых по методу ЛИФО";
	Иначе
		Заголовок = "Регистр информации о движении "+ТМЦ+", учитываемых по методу средней себестоимости";
	КонецЕсли;
	Заголовок = Заголовок +  ?(ВидОтчета = 1, " (по "+ТМЦ2+" на складе)", " (по "+ТМЦ2+ТМЦ3+")");
	
	ОбластьЗаголовок.Параметры.НачалоПериода       = Формат(НачалоПериода, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.КонецПериода        = Формат(КонецПериода, "ДФ=dd.MM.yyyy");
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация);
	НазваниеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ОбластьЗаголовок.Параметры.Заголовок 		   = Заголовок;
	ОбластьЗаголовок.Параметры.ИННОрганизации      = "" + Организация.ИНН + " / " + Организация.КПП;
	ДокументРезультат.Вывести(ОбластьЗаголовок);
	
	// Параметр для показа заголовка
	ВысотаЗаголовка = ДокументРезультат.ВысотаТаблицы;
	
	// Когда нужен только заголовок:
	Если ТолькоЗаголовок Тогда
		Возврат;
	КонецЕсли;
	
	// Проверим заполнение обязательных реквизитов
	Если НалоговыйУчет.ПроверитьЗаполнениеОбязательныхРеквизитов(ДатаНач,ДатаКон,Организация) Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;	
	
	Результат = СформироватьЗапрос();
	
	НУ = ПланыСчетов.Хозрасчетный.Товары.ПолучитьОбъект();
	ВестиСуммовойУчетПоСкладамНУ = ?(НЕ (НУ.ВидыСубконто.Найти(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады, "ВидСубконто") = Неопределено),
	                                 НУ.ВидыСубконто.Найти(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады, "ВидСубконто").Суммовой,
	                                 Ложь);
	ОбластьШапкаТаблицы  = Макет.ПолучитьОбласть("ШапкаТаблицы");
	
	Если ВидОтчета = 2 Или ВидОтчета = 3 Тогда
		Если ВидОтчета = 2 Тогда
			ОбластьШапкаТаблицы.Параметры.ЗаголовокОтгрузки = "Отгружено без перехода права собственности";
			ОбластьШапкаТаблицы.Параметры.ЗаголовокСписания = "Реализовано";
			ОбластьШапкаТаблицы.Параметры.ЗаговокВозврата = "Возврат на склад	";
		КонецЕсли;
		Если ВидОтчета = 3 Тогда
			ОбластьШапкаТаблицы.Параметры.ЗаголовокОтгрузки = "Передано";
			ОбластьШапкаТаблицы.Параметры.ЗаголовокСписания = "Переработано";
			ОбластьШапкаТаблицы.Параметры.ЗаговокВозврата = "Возвращено";
		КонецЕсли;
	КонецЕсли;
	ДокументРезультат.Вывести(ОбластьШапкаТаблицы);
	
	УчетПоСредней = (УчетнаяПолитика = Перечисления.СпособыОценки.ПоСредней);
	
	Если ВидОтчета = 1 Тогда
		ВывестиПоТМЦНаСкладе(ДокументРезультат, Макет, Результат, УчетнаяПолитика);
	Иначе
		ВывестиПоТМЦОтгруженным(ДокументРезультат, Макет, Результат, УчетнаяПолитика);
	КонецЕсли;
	
КонецПроцедуры // СформироватьОтчет

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП           = Новый НастройкаПериода;

#КонецЕсли