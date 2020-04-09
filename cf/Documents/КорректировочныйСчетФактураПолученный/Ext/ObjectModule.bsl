﻿Перем мВалютаРегламентированногоУчета Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

Функция ПолучитьРеквизитыПродавца(Контрагент, Дата) Экспорт
	
	РеквизитыПродавца = Новый Структура;
	СведенияОПродавце = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Контрагент, Дата);
	
	РеквизитыПродавца.Вставить("НаименованиеПродавца", СведенияОПродавце.НаименованиеДляПечатныхФорм);
	РеквизитыПродавца.Вставить("ИННПродавца",          СведенияОПродавце.ИНН);
	РеквизитыПродавца.Вставить("КПППродавца",          СведенияОПродавце.КПП);
	
	Возврат РеквизитыПродавца;
	
КонецФункции 

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ПОДГОТОВКИ ПЕЧАТНОЙ ФОРМЫ ДОКУМЕНТА

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМИРОВАНИЯ ДВИЖЕНИЙ ДОКУМЕНТА

Функция ПодготовитьТаблицыДокумента()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТаблицаВосстановлениеНДС.НомерСтроки КАК НомерСтроки,
	|	ТаблицаВосстановлениеНДС.Ссылка.Дата КАК Период,
	|	ТаблицаВосстановлениеНДС.Ссылка.Организация КАК Организация,
	|	ТаблицаВосстановлениеНДС.Ссылка.Контрагент КАК Покупатель,
	|	НЕОПРЕДЕЛЕНО КАК ДоговорКонтрагента,
	|	ТаблицаВосстановлениеНДС.Ссылка КАК СчетФактура,
	|	ТаблицаВосстановлениеНДС.ВидЦенности КАК ВидЦенности,
	|	ТаблицаВосстановлениеНДС.СтавкаНДС КАК СтавкаНДС,
	|	ТаблицаВосстановлениеНДС.Сумма КАК СуммаСНДС,
	|	ТаблицаВосстановлениеНДС.Сумма - ТаблицаВосстановлениеНДС.СуммаНДС КАК СуммаБезНДС,
	|	ТаблицаВосстановлениеНДС.СуммаНДС КАК НДС,
	|	ЗНАЧЕНИЕ(Перечисление.СобытияПоНДСПродажи.ВосстановлениеНДС) КАК Событие,
	|	ТаблицаВосстановлениеНДС.Ссылка.Дата КАК ДатаСобытия,
	|	ЛОЖЬ КАК ЗаписьДополнительногоЛиста,
	|	ДАТАВРЕМЯ(1, 1, 1) КАК КорректируемыйПериод,
	|	ЛОЖЬ КАК СторнирующаяЗаписьДопЛиста
	|ИЗ
	|	Документ.КорректировочныйСчетФактураПолученный.ВосстановлениеНДС КАК ТаблицаВосстановлениеНДС
	|ГДЕ
	|	ТаблицаВосстановлениеНДС.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаВычетНДС.НомерСтроки КАК НомерСтроки,
	|	ТаблицаВычетНДС.Ссылка.Дата КАК Период,
	|	ТаблицаВычетНДС.Ссылка.Организация,
	|	ТаблицаВычетНДС.Ссылка.Контрагент КАК Поставщик,
	|	НЕОПРЕДЕЛЕНО КАК ДоговорКонтрагента,
	|	ТаблицаВычетНДС.Ссылка КАК СчетФактура,
	|	ТаблицаВычетНДС.ВидЦенности КАК ВидЦенности,
	|	ТаблицаВычетНДС.СтавкаНДС КАК СтавкаНДС,
	|	ТаблицаВычетНДС.СчетУчетаНДС КАК СчетУчетаНДС,
	|	ТаблицаВычетНДС.Сумма КАК СуммаСНДС,
	|	ТаблицаВычетНДС.Сумма - ТаблицаВычетНДС.СуммаНДС КАК СуммаБезНДС,
	|	ТаблицаВычетНДС.СуммаНДС КАК НДС,
	|	ЗНАЧЕНИЕ(Перечисление.СобытияПоНДСПокупки.ПредъявленНДСКВычету) КАК Событие,
	|	ТаблицаВычетНДС.Ссылка.Дата КАК ДатаСобытия,
	|	ЛОЖЬ КАК ЗаписьДополнительногоЛиста,
	|	ДАТАВРЕМЯ(1, 1, 1) КАК КорректируемыйПериод
	|ИЗ
	|	Документ.КорректировочныйСчетФактураПолученный.ВычетНДС КАК ТаблицаВычетНДС
	|ГДЕ
	|	ТаблицаВычетНДС.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";
	
	Результат = Запрос.ВыполнитьПакет();
	
	ТаблицыДокумента = Новый Структура;
	ТаблицыДокумента.Вставить("Восстановление", Результат[0].Выгрузить());
	ТаблицыДокумента.Вставить("Вычет",          Результат[1].Выгрузить());
	
	Возврат ТаблицыДокумента;	
	
КонецФункции

Процедура ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента, ТаблицаВосстановление, ТаблицаВычет, Отказ, Заголовок)
	
	Если СтруктураШапкиДокумента.РазницаСНДСКУменьшению < ТаблицаВосстановление.Итог("СуммаСНДС") Тогда
		ТекстСообщения = НСтр("ru='Разница к уменьшению по счету-фактуре меньше восстанавливаемой суммы.'");
		ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
	КонецЕсли;
	Если СтруктураШапкиДокумента.РазницаНДСКУменьшению < ТаблицаВосстановление.Итог("НДС") Тогда
		ТекстСообщения = НСтр("ru='НДС к уменьшению по счету-фактуре меньше восстанавливаемой суммы НДС.'");
		ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
	КонецЕсли;
	Если СтруктураШапкиДокумента.РазницаСНДСКДоплате < ТаблицаВычет.Итог("СуммаСНДС") Тогда
		ТекстСообщения = НСтр("ru='Разница к доплате по счету-фактуре меньше принимаемой к вычету суммы.'");
		ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
	КонецЕсли;
	Если СтруктураШапкиДокумента.РазницаНДСКДоплате < ТаблицаВычет.Итог("НДС") Тогда
		ТекстСообщения = НСтр("ru='НДС к доплате по счету-фактуре меньше принимаемой к вычету суммы НДС.'");
		ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры

// Формирование записей книги продаж - восстановление НДС - при уменьшении стоимости (разницы к уменьшению)
//
Процедура СформироватьДвиженияУменьшениеСтоимостиПоступления(СтруктураШапкиДокумента, ТаблицаВосстановление, Отказ, Заголовок) 
	
	Если ТаблицаВосстановление.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого СтрокаТаблицы Из ТаблицаВосстановление Цикл
		
		Движение = Движения.НДСЗаписиКнигиПродаж.Добавить();
		ЗаполнитьЗначенияСвойств(Движение, СтрокаТаблицы);
		
	КонецЦикла;
		
КонецПроцедуры	

// Формирование записей книги покупок - вычет НДС - при увеличении стоимости (разницы к доплате)
//
Процедура СформироватьДвиженияУвеличениеСтоимостиПоступления(СтруктураШапкиДокумента, ТаблицаВычет, Отказ, Заголовок) 
	           	
	Если ТаблицаВычет.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого СтрокаТаблицы Из ТаблицаВычет Цикл
		
		Движение = Движения.НДСЗаписиКнигиПокупок.Добавить();
		ЗаполнитьЗначенияСвойств(Движение, СтрокаТаблицы);
		
	КонецЦикла;
		
КонецПроцедуры	

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)

	ЗаполнениеДокументов.ЗаполнитьШапкуДокумента(
		ЭтотОбъект, глЗначениеПеременной("глТекущийПользователь"), мВалютаРегламентированногоУчета, "Покупка");
	
КонецПроцедуры 

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ)

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	// Проверка ручной корректировки
	Если ОбщегоНазначения.РучнаяКорректировкаОбработкаПроведения(РучнаяКорректировка, Отказ, Заголовок, ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ТаблицыДокумента = ПодготовитьТаблицыДокумента();
	
	ПроверитьЗаполнениеДокумента(
		СтруктураШапкиДокумента, ТаблицыДокумента.Восстановление, ТаблицыДокумента.Вычет, Отказ, Заголовок);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	СформироватьДвиженияУменьшениеСтоимостиПоступления(
		СтруктураШапкиДокумента, ТаблицыДокумента.Восстановление, Отказ, Заголовок);
	
	СформироватьДвиженияУвеличениеСтоимостиПоступления(
		СтруктураШапкиДокумента, ТаблицыДокумента.Вычет, Отказ, Заголовок);	
		
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
		
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, РучнаяКорректировка, Ложь);

КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
