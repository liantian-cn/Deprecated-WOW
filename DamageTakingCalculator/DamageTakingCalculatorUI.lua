

DamageTakingCalculatorFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")



DamageTakingCalculatorFrame:SetScript("OnEvent", function(self, event, ...)
    DamageTakingCalculatorTextFrame:SetText(get_damageTP5S())
end);


