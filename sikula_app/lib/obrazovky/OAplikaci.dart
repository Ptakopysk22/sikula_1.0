import 'package:flutter/material.dart';

class OAplikaci extends StatelessWidget {
  const OAplikaci({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O aplikaci'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(10.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                    'Šikula (Šánovská Inovativní Komunikační Uživatelsky-Lákavá Aplikace) je dlouhodobý projekt, jehož cílem je zjednodušit sdílení všemožných informací na Šánu. Kromě snížení administrativní zátěže vedoucích by měl systém také vést k menší chybovosti.'),
                SizedBox(
                  height: 10,
                ),
                Text(
                    'Do budoucna je v plánu aplikaci rozšířit o funkce pro rozcvičku a obecně o všechny úkony spojené s CTB. A také dostat aplikaci na Apple zařízení. V další etapě bude následovat vývoj hospodářské databáze ověřených nákupních míst společně s nákupním seznamem propojeným s jídelníčkem pro dvojici hospodář – kuchař.'),
                SizedBox(
                  height: 10,
                ),
                Text(
                    'Místo udržování zkostnatělého a relativně pracného systému, pojďme ušetřený čas využívat účelněji.'),
                SizedBox(
                  height: 10,
                ),
                Text(
                    'Pokud tě aplikace zaujala a rád by ses podílel na jejím zdokonalování (UI, UX, testování, programování ...), neváhej kontaktovat vývojáře.'),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text('Fíla, 2024')],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
