﻿
Процедура ПередЗаписью(Отказ) 
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Владелец.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо 
		И ОбособленноеПодразделение Тогда
		Если НЕ ЗначениеЗаполнено(РегистрацияВИФНС) Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Не указаны сведения о регистрации в ИФНС.",,, СтатусСообщения.Важное);
			Отказ = Истина;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ОбработкаИзмененияРодителя(Родитель, Отказ);
	
КонецПроцедуры

Процедура ОбработкаИзмененияРодителя(РодительПодразделения, Отказ = Ложь) Экспорт
	
	Отказ = Ложь;
	
	Если ОбособленноеПодразделение Тогда
		Возврат;
	КонецЕсли;
	
	Если РодительПодразделения = Справочники.ПодразделенияОрганизаций.ПустаяСсылка() Тогда
		Возврат;
	КонецЕсли;
	
	Если РодительПодразделения.ОбособленноеПодразделение Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Указанное подразделение является обособленным.",,, СтатусСообщения.Важное);
		ОбщегоНазначения.СообщитьОбОшибке("В группу обособленных подразделений может входить только обособленное подразделение.",,, СтатусСообщения.Информация);
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

