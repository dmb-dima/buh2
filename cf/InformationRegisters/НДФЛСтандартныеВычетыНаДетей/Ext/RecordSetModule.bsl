﻿
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

Процедура ЗаполнитьКоличествоДетейЗавершения(НаборЗаписей)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Данные",НаборЗаписей.Выгрузить());
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НДФЛСтандартныеВычетыНаДетей.Период,
	|	НДФЛСтандартныеВычетыНаДетей.Физлицо,
	|	НДФЛСтандартныеВычетыНаДетей.КодВычета,
	|	НДФЛСтандартныеВычетыНаДетей.ПериодЗавершения,
	|	НДФЛСтандартныеВычетыНаДетей.КоличествоДетей,
	|	НДФЛСтандартныеВычетыНаДетей.Основание
	|ПОМЕСТИТЬ ВТНаборЗаписей
	|ИЗ
	|	&Данные КАК НДФЛСтандартныеВычетыНаДетей
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СрезПоследних.Период,
	|	СрезПоследних.Физлицо,
	|	СрезПоследних.КодВычета,
	|	СрезПоследних.ПериодЗавершения,
	|	СрезПоследних.КоличествоДетей,
	|	НаборЗаписейОснование.Основание,
	|	ВЫБОР
	|		КОГДА НДФЛСтандартныеВычетыНаДетей.ПериодЗавершения <= СрезПоследних.Период
	|				И НДФЛСтандартныеВычетыНаДетей.ПериодЗавершения <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|			ТОГДА НДФЛСтандартныеВычетыНаДетей.КоличествоДетейЗавершения
	|		ИНАЧЕ НДФЛСтандартныеВычетыНаДетей.КоличествоДетей
	|	КОНЕЦ КАК КоличествоДетейЗавершения
	|ИЗ
	|	(ВЫБРАТЬ
	|		НаборЗаписей.Период КАК Период,
	|		НаборЗаписей.Физлицо КАК Физлицо,
	|		НаборЗаписей.КодВычета КАК КодВычета,
	|		НаборЗаписей.ПериодЗавершения КАК ПериодЗавершения,
	|		НаборЗаписей.КоличествоДетей КАК КоличествоДетей,
	|		МАКСИМУМ(НДФЛСтандартныеВычетыНаДетей.Период) КАК ПериодСреза
	|	ИЗ
	|		ВТНаборЗаписей КАК НаборЗаписей
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НДФЛСтандартныеВычетыНаДетей КАК НДФЛСтандартныеВычетыНаДетей
	|			ПО НаборЗаписей.Физлицо = НДФЛСтандартныеВычетыНаДетей.Физлицо
	|				И НаборЗаписей.КодВычета = НДФЛСтандартныеВычетыНаДетей.КодВычета
	|				И НаборЗаписей.Период > НДФЛСтандартныеВычетыНаДетей.Период
	|	
	|	СГРУППИРОВАТЬ ПО
	|		НаборЗаписей.Период,
	|		НаборЗаписей.Физлицо,
	|		НаборЗаписей.КодВычета,
	|		НаборЗаписей.ПериодЗавершения,
	|		НаборЗаписей.КоличествоДетей) КАК СрезПоследних
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НДФЛСтандартныеВычетыНаДетей КАК НДФЛСтандартныеВычетыНаДетей
	|		ПО СрезПоследних.Физлицо = НДФЛСтандартныеВычетыНаДетей.Физлицо
	|			И СрезПоследних.КодВычета = НДФЛСтандартныеВычетыНаДетей.КодВычета
	|			И СрезПоследних.ПериодСреза = НДФЛСтандартныеВычетыНаДетей.Период
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТНаборЗаписей КАК НаборЗаписейОснование
	|		ПО СрезПоследних.Физлицо = НаборЗаписейОснование.Физлицо
	|			И СрезПоследних.КодВычета = НаборЗаписейОснование.КодВычета
	|			И СрезПоследних.Период = НаборЗаписейОснование.Период";
	
	НаборЗаписей.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
        Возврат;
    КонецЕсли;

	Если Количество() > 0 Тогда
		ЗаполнитьКоличествоДетейЗавершения(ЭтотОбъект)	
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
        Возврат;
    КонецЕсли;

	Если Количество() > 0 Тогда
		
	Иначе
		
	КонецЕсли;
	
КонецПроцедуры
