local _,Bags=...
function Bags:BuildOptions(parent)
    local title=self:Text(parent,"PatchToolsBags · 0.1.5",16); title:SetPoint("TOPLEFT",0,-5)
    local intro=self:Text(parent,self:T("Your bags and bank in a compact window.","Deine Taschen und Bank in einem kompakten Fenster."),12)
    intro:SetPoint("TOPLEFT",0,-43); intro:SetWidth(560); intro:SetJustifyH("LEFT")
    local function Check(y,en,de,key)
        local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
        b:SetPoint("TOPLEFT",0,y); b:SetChecked(Bags.db[key])
        local label=Bags:Text(b,Bags:T(en,de),13); label:SetPoint("LEFT",b,"RIGHT",4,0)
        b:SetScript("OnClick",function()
            Bags.db[key]=b:GetChecked() and true or false
            if key=="replaceBags" and Bags.owner.isForever and Bags.MaskNativeCarriedBags then
                Bags:MaskNativeCarriedBags(Bags:CanReplace())
            end
            if Bags.UpdateBankReplacement and (key=="replaceBank" or key=="replaceBags") then Bags:UpdateBankReplacement() end
            Bags:QueueRefresh()
        end)
    end
    Check(-90,"Replace the standard bag window","Standard-Taschenfenster ersetzen","replaceBags")
    Check(-126,"Use the compact bank window at the banker","Kompaktes Bankfenster beim Bankier verwenden","replaceBank")
    local hint=self:Text(parent,self:T("Other bag addons take priority while enabled. /ptbags always opens this window.","Andere aktive Taschen-Addons haben Vorrang. /ptbags öffnet dieses Fenster jederzeit."),12)
    hint:SetPoint("TOPLEFT",36,-161); hint:SetWidth(510); hint:SetJustifyH("LEFT")
    Check(-194,"Show quest, protection and sale markers","Quest-, Schutz- und Verkaufsmarkierungen anzeigen","markers")
    Check(-224,"Show Pawn upgrade arrows","Pawn-Verbesserungen anzeigen","pawnUpgrades")
    Check(-254,"Sort bags and bank when opened","Taschen und Bank beim Öffnen sortieren","autoSortOnOpen")
    Check(-284,"Move items into matching specialty bags when sorting","Beim Sortieren in passende Spezialtaschen einräumen","sortSpecialtyBags")
    local function Slider(y,en,de,key,lo,hi,step)
        local settings=(key=="scale" or key=="columns") and Bags.windowDB or Bags.db
        local label=Bags:Text(parent,"",13); label:SetPoint("TOPLEFT",0,y)
        local slider=CreateFrame("Slider","PatchToolsBagsOption"..key,parent,"OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT",0,y-30); slider:SetWidth(440)
        slider:SetMinMaxValues(lo,hi); slider:SetValueStep(step); slider:SetObeyStepOnDrag(true)
        _G[slider:GetName().."Low"]:SetText(tostring(lo)); _G[slider:GetName().."High"]:SetText(tostring(hi))
        slider:SetScript("OnValueChanged",function(_,value)
            value=math.floor(value/step+0.5)*step
            settings[key]=value
            label:SetText(Bags:T(en,de)..": "..((key=="scale" or key=="backgroundTransparency") and math.floor(value*100+0.5).."%" or tostring(value)))
            Bags:QueueRefresh()
        end)
        slider:SetValue(settings[key])
    end
    Slider(-310,"Bag window scale","Taschenfensterskalierung","scale",0.65,1.3,0.05)
    Slider(-375,"Bag columns","Taschenspalten","columns",6,16,1)
    Slider(-440,"Background transparency (bags and bank)","Hintergrundtransparenz (Taschen und Bank)","backgroundTransparency",0,0.8,0.01)
    local reset=self:Button(parent,self:T("Reset position and size","Position und Größe zurücksetzen"),300,function()
        self.windowDB.x=nil; self.windowDB.y=nil; self.windowDB.scale=1; self.windowDB.columns=10
        self:ResetBankWindow()
        PatchToolsBagsOptionscale:SetValue(1)
        PatchToolsBagsOptioncolumns:SetValue(10)
        self:CreateWindow(); self:PlaceWindow(); self:QueueRefresh()
    end)
    reset:SetWidth(280); reset:SetPoint("TOPLEFT",0,-510)
    local native=self:Button(parent,self:T("Open Blizzard bank","Blizzard-Bank öffnen"),230,function() self:OpenNativeBank() end)
    native:SetPoint("TOPLEFT",290,-510)
    local note=self:Text(parent,self:T("Drag the title to move; drag the lower right corner to scale.\nCombat sorting changes the display only. Reset: /ptbags reset","Titelleiste ziehen: verschieben. Ecke unten rechts ziehen: skalieren.\nIm Kampf wird nur die Anzeige sortiert. Reset: /ptbags reset"),12)
    note:SetPoint("TOPLEFT",0,-548); note:SetWidth(560); note:SetJustifyH("LEFT")
end
