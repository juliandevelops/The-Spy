package dev.jules.thespy

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource


@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun Welcome(
    onNavigateNew: () -> Unit,
    onNavigateCats: () -> Unit,
    onNavigateConfig: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.welcome)) })
        }
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth()
                .padding(it),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,

            ) {
            Button(onClick = { onNavigateNew() }) {
                Text(stringResource(R.string.new_game))
            }
            Button(onClick = { onNavigateCats() }) {
                Text(stringResource(R.string.categories))
            }
            Button(onClick = { onNavigateConfig() }) {
                Text(stringResource(R.string.further_configuration))
            }
        }
    }
}
