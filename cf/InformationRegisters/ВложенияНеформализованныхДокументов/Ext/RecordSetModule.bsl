﻿
Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
	Если КонтекстЭДО <> Неопределено Тогда
		КонтекстЭДО.ПередЗаписьюОбъекта(ЭтотОбъект, Отказ, , , Замещение);
	КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
	Если КонтекстЭДО <> Неопределено Тогда
		КонтекстЭДО.ПриЗаписиОбъекта(ЭтотОбъект, Отказ, Замещение);
	КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры
