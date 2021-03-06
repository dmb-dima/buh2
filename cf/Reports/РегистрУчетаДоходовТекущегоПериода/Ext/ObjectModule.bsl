﻿#Если Клиент Тогда
	
Перем НП Экспорт;

Перем CписокСчетов;
Перем Счет91_01;
Перем Счет90_01;

// Определяет вид дохода в зависимости от операции и параметров операции
//
Функция ВидДоходаПоОперации(Счет, Субконто1, Субконто2, Субконто3, ВидДоходов, Контрагент, Договор)

	ОбъектУчета = "";
	ВидДохода   = "";

	Если      Счет = Счет90_01 ИЛИ Счет.ПринадлежитЭлементу(Счет90_01) Тогда
		ВидДохода   = "Выручка от реализации товаров, работ, услуг";
		ОбъектУчета = Строка(Субконто3);
		
	ИначеЕсли Счет = Счет91_01 ИЛИ Счет.ПринадлежитЭлементу(Счет91_01) Тогда

	Если Субконто1.ВидПрочихДоходовИРасходов =  Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейОсновныхСредств Тогда
		ВидДохода   = "Выручка от реализации ОС";
		ОбъектУчета = Строка(Субконто2);

	ИначеЕсли Субконто1.ВидПрочихДоходовИРасходов =  Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейНематериальныхАктивов Тогда
		ВидДохода   = "Выручка от реализации НМА";
		ОбъектУчета = Строка(Субконто2);

	ИначеЕсли Субконто1.ВидПрочихДоходовИРасходов =  Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейПрочегоИмущества Тогда
		ВидДохода   = "Выручка от реализации прочего имущества";
		ОбъектУчета = Строка(Субконто2);
		
	ИначеЕсли Субконто1.ВидПрочихДоходовИРасходов =  Перечисления.ВидыПрочихДоходовИРасходов.КурсовыеРазницыПоРасчетамВУЕ Тогда
		ВидДохода   = "Внереализационные доходы";
		ОбъектУчета = "Суммовые разницы по расчетам по договорам в у.е.";
			
			Если ЗначениеЗаполнено(Контрагент) тогда
				ОбъектУчета = Контрагент + " (" + Договор + ")";
			КонецЕсли;
		
		
	ИначеЕсли ВидДоходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейПраваТребованияКакОказанияФинансовыхУслуг Тогда
			ВидДохода   = "Выручка от реализации прав требования";

			
			Если ЗначениеЗаполнено(Контрагент) тогда
				ОбъектУчета = Контрагент + " (" + Договор + ")";
			КонецЕсли;
			
		ИначеЕсли ВидДоходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейПраваТребованияДоНаступленияСрокаПлатежа Тогда
			ВидДохода   = "Выручка от уступки права до наступления срока платежа";
			
			Если ЗначениеЗаполнено(Контрагент) тогда
				ОбъектУчета = Контрагент + " (" + Договор + ")";
			КонецЕсли;
	
		ИначеЕсли  ВидДоходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейПраваТребованияПослеНаступленияСрокаПлатежа Тогда
			ВидДохода   = "Выручка от уступки права после наступления срока платежа";

			Если ЗначениеЗаполнено(Контрагент) тогда
				ОбъектУчета = Контрагент + " (" + Договор + ")";
			КонецЕсли;
			
	ИначеЕсли  ВидДоходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыСвязанныеСРеализациейЦенныхБумаг  Тогда
		ВидДохода   = "Выручка от реализации ЦБ";
		ОбъектУчета = Строка(Субконто2);

	Иначе
		Если ВидДоходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыПоОперациямСФинансовымиИнструментамиСрочныхСделок Тогда
			ВидДохода   = "Доходы по операциям с финансовыми инструментами срочных сделок, не обращающимися на организованном рынке";

		Иначе
			ВидДохода   = "Внереализационные доходы";
			ОбъектУчета = Строка(ВидДоходов);

		КонецЕсли;
	КонецЕсли;
КонецЕсли;

	Возврат Новый Структура("ВидДохода, ОбъектУчета", ВидДохода, ОбъектУчета);

КонецФункции // ВидДоходаПоОперации

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь) Экспорт

	ДокументРезультат.Очистить();

	Макет = ПолучитьМакет("Отчет");

	ОбластьЗаголовок  = Макет.ПолучитьОбласть("Заголовок");

	ОбластьЗаголовок.Параметры.НачалоПериода       = Формат(ДатаНач, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.КонецПериода        = Формат(ДатаКон, "ДФ=dd.MM.yyyy");
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация);
	НазваниеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ОбластьЗаголовок.Параметры.ИННОрганизации      = "" + Организация.ИНН + " / " + Организация.КПП;
	
	ВидыДохода = "";
	Для Каждого ЭлементСписка из ВидыДоходов Цикл
		Если ЭлементСписка.Пометка Тогда
			ВидыДохода = ВидыДохода + ЭлементСписка.Значение + "
			|";
		КонецЕсли;
	КонецЦикла;
	ОбластьЗаголовок.Параметры.ВидыДохода = ВидыДохода;

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

	Запрос = Новый Запрос;

	Запрос.УстановитьПараметр("ДатаНач",      НачалоДня(ДатаНач));
	Запрос.УстановитьПараметр("ДатаКон",      КонецДня(ДатаКон));
	Запрос.УстановитьПараметр("СписокСчетов", CписокСчетов);
	Запрос.УстановитьПараметр("Организация",  Организация);
	Запрос.УстановитьПараметр("Счет90",  Счет90_01);
	Запрос.УстановитьПараметр("Счет91",  Счет91_01);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ХозрасчетныйОборотыДтКт.Период КАК ДатаОперации,
	|	ХозрасчетныйОборотыДтКт.СчетКт КАК СчетКт,
	|	ЕСТЬNULL(ХозрасчетныйОборотыДтКт.СуммаНУОборотКт, 0) КАК Сумма,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт2,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт3,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1.Наименование КАК ВидДоходов,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт2.НаименованиеПолное КАК Контрагент,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт3.Представление КАК Договор,
	|	ХозрасчетныйОборотыДтКт.Регистратор
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&ДатаНач, &ДатаКон, Запись, , , СчетКт В ИЕРАРХИИ (&Счет90), , Организация = &Организация) КАК ХозрасчетныйОборотыДтКт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ХозрасчетныйОборотыДтКт.Период,
	|	ХозрасчетныйОборотыДтКт.СчетКт,
	|	ЕСТЬNULL(ХозрасчетныйОборотыДтКт.СуммаНУОборотКт, 0),
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт2,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт3,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1.ВидПрочихДоходовИРасходов,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт2.НаименованиеПолное,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт3.Представление,
	|	ХозрасчетныйОборотыДтКт.Регистратор
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(
	|			&ДатаНач,
	|			&ДатаКон,
	|			Запись,
	|			,
	|			,
	|			СчетКт В ИЕРАРХИИ (&Счет91),
	|			,
	|			Организация = &Организация) КАК ХозрасчетныйОборотыДтКт
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаОперации
	|ИТОГИ
	|	СУММА(Сумма)
	|ПО
	|	СчетКт";
	Результат = Запрос.Выполнить();

	ОбластьПодвал        = Макет.ПолучитьОбласть("Подвал");
	ОбластьШапкаТаблицы  = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьПодвалТаблицы = Макет.ПолучитьОбласть("ПодвалТаблицы");
	ОбластьСтрока        = Макет.ПолучитьОбласть("Строка");

	ДокументРезультат.Вывести(ОбластьШапкаТаблицы);

	Выборка = Результат.Выбрать();
	Итого   = 0;

	СписокВидов = Новый СписокЗначений();
	Для Каждого ЭлементСписка из ВидыДоходов Цикл
		Если ЭлементСписка.Пометка Тогда
			СписокВидов.Добавить(ЭлементСписка.Значение);
		КонецЕсли;
	КонецЦикла;

	Пока Выборка.Следующий() Цикл
		Если Не ЗначениеЗаполнено(Выборка.ДатаОперации) Тогда
			Продолжить;
		КонецЕсли;

		СтруктураВида = ВидДоходаПоОперации(Выборка.СчетКт,
		                                    Выборка.СубконтоКт1, Выборка.СубконтоКт2, Выборка.СубконтоКт3, 
		                                    Выборка.ВидДоходов,  Выборка.Контрагент,  Выборка.Договор);

		Если СписокВидов.НайтиПоЗначению(СтруктураВида.ВидДохода) = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ОбластьСтрока.Параметры.ДатаОперации = Выборка.ДатаОперации;
		ОбластьСтрока.Параметры.ВидДохода    = СтруктураВида.ВидДохода;
		ОбластьСтрока.Параметры.ОбъектУчета  = СтруктураВида.ОбъектУчета;
		ОбластьСтрока.Параметры.Сумма        = Выборка.Сумма;
		ОбластьСтрока.Параметры.Расшифровка  = Выборка.Регистратор;

		ДокументРезультат.Вывести(ОбластьСтрока);

		Итого = Итого + Выборка.Сумма;

	КонецЦикла;

	ОбластьПодвалТаблицы.Параметры.ИтогоСуммаДохода = Итого;
	ДокументРезультат.Вывести(ОбластьПодвалТаблицы);

	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);
	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = СтруктураЛиц.ОтветственныйЗаРегистры;
	ДокументРезультат.Вывести(ОбластьПодвал);

КонецПроцедуры // СформироватьОтчет

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП           = Новый НастройкаПериода;

Счет91_01    = ПланыСчетов.Хозрасчетный.ПрочиеДоходы;
Счет90_01  = ПланыСчетов.Хозрасчетный.Выручка;

CписокСчетов = Новый СписокЗначений();
CписокСчетов.Добавить(Счет90_01);
CписокСчетов.Добавить(Счет91_01);

#КонецЕсли