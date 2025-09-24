import { Health } from '@capgo/capacitor-health';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Health.echo({ value: inputValue })
}
